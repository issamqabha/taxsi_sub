import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class TripProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  List<TripModel> _trips = [];
  bool _isLoading = false;
  String? _error;
  String? _customerId;

  // Getters
  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with customer ID
  void initializeCustomer(String customerId) {
    _customerId = customerId;
    loadTrips();
  }

  // Load all trips for customer
  Future<void> loadTrips() async {
    if (_customerId == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _trips = await _firestoreService.getTrips(_customerId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load trips: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get trips stream for customer
  Stream<List<TripModel>> getTripsStream(String customerId) {
    return _firestoreService.getTripsStream(customerId);
  }

  // Get weekly trips
  Future<List<TripModel>> getWeeklyTrips(int weekNumber, int year) async {
    if (_customerId == null) return [];

    try {
      return await _firestoreService.getWeeklyTrips(_customerId!, weekNumber, year);
    } catch (e) {
      _error = 'Failed to load weekly trips: $e';
      notifyListeners();
      return [];
    }
  }

  // Get monthly trips
  Future<List<TripModel>> getMonthlyTrips(int monthNumber, int year) async {
    if (_customerId == null) return [];

    try {
      return await _firestoreService.getMonthlyTrips(_customerId!, monthNumber, year);
    } catch (e) {
      _error = 'Failed to load monthly trips: $e';
      notifyListeners();
      return [];
    }
  }

  // Get trips count for today
  int getTodayTripsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _trips.where((trip) {
      final tripDate = DateTime(trip.dateTime.year, trip.dateTime.month, trip.dateTime.day);
      return tripDate == today;
    }).length;
  }

  // Get trips count by type for current week
  Map<String, int> getWeeklyTripsCounts() {
    final now = DateTime.now();
    final currentWeek = _getWeekNumber(now);
    final currentYear = now.year;

    int toWorkCount = 0;
    int returnCount = 0;

    for (var trip in _trips) {
      if (trip.weekNumber == currentWeek && trip.year == currentYear) {
        if (trip.type == TripType.toWork) {
          toWorkCount++;
        } else {
          returnCount++;
        }
      }
    }

    return {
      'toWork': toWorkCount,
      'return': returnCount,
    };
  }

  // Get total revenue for current month
  double getMonthlyRevenue() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    double revenue = 0;

    for (var trip in _trips) {
      if (trip.monthNumber == currentMonth && trip.year == currentYear) {
        revenue += trip.price;
      }
    }

    return revenue;
  }

  // Delete trip
  Future<bool> deleteTrip(String tripId, String subscriptionId, double tripPrice) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Cancel reminder if exists
      final tripIndex = _trips.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1 && _trips[tripIndex].reminderTime != null) {
        await _notificationService.cancelReminder(tripId.hashCode);
      }

      await _firestoreService.deleteTrip(tripId, subscriptionId, tripPrice);
      await loadTrips();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete trip: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Schedule reminder for trip
  Future<void> scheduleReminder({
    required String tripId,
    required String customerName,
    required String tripTime,
    required DateTime reminderDateTime,
  }) async {
    try {
      await _notificationService.scheduleReminder(
        id: tripId.hashCode,
        tripId: tripId,
        customerName: customerName,
        tripTime: tripTime,
        reminderDateTime: reminderDateTime,
      );

      // Update trip with reminder time in Firestore
      final tripIndex = _trips.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1) {
        final updatedTrip = _trips[tripIndex].copyWith(reminderTime: reminderDateTime);
        await _firestoreService.updateTrip(updatedTrip);
        _trips[tripIndex] = updatedTrip;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to schedule reminder: $e';
      notifyListeners();
    }
  }

  // Cancel reminder for trip
  Future<void> cancelReminder(String tripId) async {
    try {
      await _notificationService.cancelReminder(tripId.hashCode);

      // Clear reminder time from Firestore
      final tripIndex = _trips.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1) {
        final updatedTrip = _trips[tripIndex].copyWith(reminderTime: null);
        await _firestoreService.updateTrip(updatedTrip);
        _trips[tripIndex] = updatedTrip;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to cancel reminder: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to calculate week number
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(startOfYear).inDays;
    return (difference / 7).ceil();
  }
}
