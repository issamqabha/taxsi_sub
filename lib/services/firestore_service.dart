import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/subscription_model.dart';
import '../models/trip_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== CUSTOMER OPERATIONS =====

  // Add a new customer
  Future<CustomerModel> addCustomer({
    required String driverId,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      print('[FIRESTORE] addCustomer: driverId=$driverId, name=$name, phone=$phoneNumber');
      
      final docRef = _firestore.collection('customers').doc();
      final customer = CustomerModel(
        id: docRef.id,
        driverId: driverId,
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        isActive: true,
      );

      print('[FIRESTORE] About to save customer to Firestore: ${customer.toMap()}');
      await docRef.set(customer.toMap());
      print('[FIRESTORE] Customer saved successfully with id: ${customer.id}');
      
      return customer;
    } catch (e) {
      print('[FIRESTORE] addCustomer error: $e');
      rethrow;
    }
  }

  // Get all customers for a driver
  Future<List<CustomerModel>> getCustomers(String driverId) async {
    try {
      print('[FIRESTORE] getCustomers called with driverId: $driverId');
      // Filter by driver ID
      final snapshot = await _firestore
          .collection('customers')
          .where('driverId', isEqualTo: driverId)
          .get();
      print('[FIRESTORE] Found ${snapshot.docs.length} customers for driver $driverId');
      
      final customers = snapshot.docs.map((doc) {
        print('[FIRESTORE] Customer: id=${doc.id}, driverId=${doc['driverId']}, name=${doc['name']}');
        return CustomerModel.fromMap(doc.data());
      }).toList();
      
      // Sort by creation date (newest first)
      customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('[FIRESTORE] Returning ${customers.length} customers to UI');
      return customers;
    } catch (e) {
      print('[FIRESTORE] ERROR in getCustomers: $e');
      rethrow;
    }
  }

  // Stream of customers for a driver (real-time updates)
  Stream<List<CustomerModel>> getCustomersStream(String driverId) {
    print('[FIRESTORE] getCustomersStream called with driverId: $driverId');
    return _firestore
        .collection('customers')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
          print('[FIRESTORE] Stream: Found ${snapshot.docs.length} customers for driver $driverId');
          final customers = snapshot.docs.map((doc) {
            print('[FIRESTORE] Stream: Customer id=${doc.id}, name=${doc['name']}');
            return CustomerModel.fromMap(doc.data());
          }).toList();
          customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          print('[FIRESTORE] Stream: Returning ${customers.length} customers to UI');
          return customers;
        });
  }

  // Update customer
  Future<void> updateCustomer(String customerId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('customers').doc(customerId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      // Delete all related subscriptions
      final subscriptions = await _firestore
          .collection('subscriptions')
          .where('customerId', isEqualTo: customerId)
          .get();

      for (var doc in subscriptions.docs) {
        await doc.reference.delete();
      }

      // Delete all related trips
      final trips = await _firestore
          .collection('trips')
          .where('customerId', isEqualTo: customerId)
          .get();

      for (var doc in trips.docs) {
        await doc.reference.delete();
      }

      // Delete customer
      await _firestore.collection('customers').doc(customerId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===== SUBSCRIPTION OPERATIONS =====

  // Add a new subscription
  Future<SubscriptionModel> addSubscription({
    required String customerId,
    required SubscriptionType type,
    required double fee,
    required double oneWayPrice,
    required double returnPrice,
  }) async {
    try {
      final docRef = _firestore.collection('subscriptions').doc();
      final subscription = SubscriptionModel(
        id: docRef.id,
        customerId: customerId,
        type: type,
        fee: fee,
        oneWayPrice: oneWayPrice,
        returnPrice: returnPrice,
        currentBalance: fee,
        tripsUsed: 0,
        startDate: DateTime.now(),
        isPaid: true,
      );

      await docRef.set(subscription.toMap());
      return subscription;
    } catch (e) {
      rethrow;
    }
  }

  // Get subscription for a customer
  Future<SubscriptionModel?> getSubscription(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('customerId', isEqualTo: customerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return SubscriptionModel.fromMap(snapshot.docs.first.data());
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Stream of subscription for a customer
  Stream<SubscriptionModel?> getSubscriptionStream(String customerId) {
    return _firestore
        .collection('subscriptions')
        .where('customerId', isEqualTo: customerId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return SubscriptionModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    });
  }

  // Update subscription
  Future<void> updateSubscription(String subscriptionId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('subscriptions').doc(subscriptionId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get all subscriptions for a customer
  Future<List<SubscriptionModel>> getSubscriptionsForCustomer(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('customerId', isEqualTo: customerId)
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting subscriptions: $e');
      return [];
    }
  }

  // Update subscription reminder time
  Future<void> updateSubscriptionReminder(String subscriptionId, DateTime? reminderTime) async {
    try {
      await _firestore.collection('subscriptions').doc(subscriptionId).update({
        'reminderTime': reminderTime,
      });
    } catch (e) {
      print('Error updating subscription reminder: $e');
      rethrow;
    }
  }

  // ===== TRIP OPERATIONS =====

  // Add a new trip
  Future<TripModel> addTrip({
    required String customerId,
    required String driverId,
    required TripType type,
    required double price,
  }) async {
    try {
      // Get subscription to calculate week/month
      final subscription = await getSubscription(customerId);
      if (subscription == null) {
        throw Exception('No active subscription found');
      }

      final now = DateTime.now();
      final docRef = _firestore.collection('trips').doc();

      final trip = TripModel(
        id: docRef.id,
        customerId: customerId,
        driverId: driverId,
        type: type,
        price: price,
        dateTime: now,
        weekNumber: _getWeekNumber(now),
        monthNumber: now.month,
        year: now.year,
      );

      // Add trip to Firestore
      await docRef.set(trip.toMap());

      // Update subscription balance and trips used
      final newBalance = subscription.currentBalance - price;
      await updateSubscription(subscription.id, {
        'currentBalance': newBalance,
        'tripsUsed': subscription.tripsUsed + 1,
      });

      // Update customer's lastTripDate
      await updateCustomer(customerId, {'lastTripDate': now});

      return trip;
    } catch (e) {
      rethrow;
    }
  }

  // Get trips for a customer
  Future<List<TripModel>> getTrips(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('customerId', isEqualTo: customerId)

          .get();

      return snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Stream of trips for a customer
  Stream<List<TripModel>> getTripsStream(String customerId) {
    return _firestore
        .collection('trips')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList());
  }

  // Get trips for a specific week
  Future<List<TripModel>> getWeeklyTrips(String customerId, int weekNumber, int year) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('customerId', isEqualTo: customerId)
          .where('weekNumber', isEqualTo: weekNumber)
          .where('year', isEqualTo: year)
          .get();

      return snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get trips for a specific month
  Future<List<TripModel>> getMonthlyTrips(String customerId, int monthNumber, int year) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('customerId', isEqualTo: customerId)
          .where('monthNumber', isEqualTo: monthNumber)
          .where('year', isEqualTo: year)
          .get();

      return snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Delete trip
  Future<void> deleteTrip(String tripId, String subscriptionId, double tripPrice) async {
    try {
      // Get current subscription
      final subscription = await _firestore.collection('subscriptions').doc(subscriptionId).get();

      if (subscription.exists) {
        // Refund the trip price
        final currentBalance = subscription['currentBalance'] as double;
        await _firestore.collection('subscriptions').doc(subscriptionId).update({
          'currentBalance': currentBalance + tripPrice,
          'tripsUsed': (subscription['tripsUsed'] as int) - 1,
        });
      }

      // Delete trip
      await _firestore.collection('trips').doc(tripId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Update trip (for reminder scheduling)
  Future<void> updateTrip(TripModel trip) async {
    try {
      await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }

  // ===== HELPER METHODS =====

  // Calculate week number from date
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(startOfYear).inDays;
    return (difference / 7).ceil();
  }

  // Get driver's statistics
  Future<Map<String, dynamic>> getDriverStatistics(String driverId) async {
    try {
      // Get total customers
      final customersSnapshot = await _firestore
          .collection('customers')
          .where('driverId', isEqualTo: driverId)
          .get();

      // Get all trips
      final tripsSnapshot = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .get();

      // Get total revenue
      double totalRevenue = 0;
      for (var trip in tripsSnapshot.docs) {
        totalRevenue += trip['price'] as double;
      }

      // Get today's trips
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final todayTripsSnapshot = await _firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .where('dateTime', isGreaterThanOrEqualTo: todayStart)
          .where('dateTime', isLessThanOrEqualTo: todayEnd)
          .get();

      return {
        'totalCustomers': customersSnapshot.docs.length,
        'totalTrips': tripsSnapshot.docs.length,
        'totalRevenue': totalRevenue,
        'todayTrips': todayTripsSnapshot.docs.length,
      };
    } catch (e) {
      rethrow;
    }
  }
}
