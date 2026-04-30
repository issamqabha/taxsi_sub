import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../models/trip_model.dart';
import '../services/firestore_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, SubscriptionModel?> _subscriptions = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get subscription for customer
  SubscriptionModel? getSubscription(String customerId) {
    return _subscriptions[customerId];
  }

  // Get subscription stream for customer
  Stream<SubscriptionModel?> getSubscriptionStream(String customerId) {
    return _firestoreService.getSubscriptionStream(customerId);
  }

  // Load subscription for customer
  Future<void> loadSubscription(String customerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subscription = await _firestoreService.getSubscription(customerId);
      _subscriptions[customerId] = subscription;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load subscription: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add subscription
  Future<bool> addSubscription({
    required String customerId,
    required SubscriptionType type,
    required double fee,
    required double oneWayPrice,
    required double returnPrice,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subscription = await _firestoreService.addSubscription(
        customerId: customerId,
        type: type,
        fee: fee,
        oneWayPrice: oneWayPrice,
        returnPrice: returnPrice,
      );

      _subscriptions[customerId] = subscription;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add subscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update subscription
  Future<bool> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateSubscription(subscriptionId, data);

      // Update local cache
      for (var entry in _subscriptions.entries) {
        if (entry.value?.id == subscriptionId) {
          // Reload subscription
          await loadSubscription(entry.key);
          break;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update subscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add trip to subscription
  Future<TripModel?> addTrip({
    required String customerId,
    required String driverId,
    required TripType type,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subscription = _subscriptions[customerId];
      if (subscription == null) {
        _error = 'No active subscription found';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Determine trip price based on type
      final tripPrice =
          type == TripType.toWork ? subscription.oneWayPrice : subscription.returnPrice;

      // Check if balance is sufficient
      if (subscription.currentBalance < tripPrice) {
        _error = 'Insufficient balance';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final trip = await _firestoreService.addTrip(
        customerId: customerId,
        driverId: driverId,
        type: type,
        price: tripPrice,
      );

      // Update local subscription
      await loadSubscription(customerId);

      _isLoading = false;
      notifyListeners();
      return trip;
    } catch (e) {
      _error = 'Failed to add trip: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get subscriptions for customer
  Future<List<SubscriptionModel>> getSubscriptionsForCustomer(String customerId) async {
    try {
      return await _firestoreService.getSubscriptionsForCustomer(customerId);
    } catch (e) {
      _error = 'Failed to get subscriptions: $e';
      notifyListeners();
      return [];
    }
  }

  // Update subscription reminder
  Future<bool> updateSubscriptionReminder(
    String subscriptionId,
    DateTime? reminderTime,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateSubscriptionReminder(subscriptionId, reminderTime);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update reminder: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
