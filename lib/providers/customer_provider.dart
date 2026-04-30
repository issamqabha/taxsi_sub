import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/firestore_service.dart';

class CustomerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _error;
  String? _driverId;

  // Getters
  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with driver ID
  void initializeDriver(String driverId) {
    print('CustomerProvider.initializeDriver called with: $driverId');
    _driverId = driverId;
    loadCustomers();
  }

  // Load customers
  Future<void> loadCustomers() async {
    if (_driverId == null) {
      print('loadCustomers: _driverId is null!');
      return;
    }

    print('loadCustomers: _driverId = $_driverId');
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _customers = await _firestoreService.getCustomers(_driverId!);
      print('loadCustomers: Got ${_customers.length} customers');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customers: $e';
      print('loadCustomers error: $_error');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get customers stream
  Stream<List<CustomerModel>> getCustomersStream() {
    if (_driverId == null) {
      return Stream.value([]);
    }
    return _firestoreService.getCustomersStream(_driverId!);
  }

  // Add customer - returns customer ID on success, null on failure
  Future<String?> addCustomer({
    required String name,
    String? phoneNumber,
  }) async {
    // If no driver ID, use a test ID for now
    final driverId = _driverId ?? 'TEST_DRIVER_${DateTime.now().millisecondsSinceEpoch}';
    print('[PROVIDER] Using driverId: $driverId (original: $_driverId)');

    try {
      print('[PROVIDER] addCustomer: name=$name, phone=$phoneNumber, driverId=$driverId');
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('[PROVIDER] Calling firestore.addCustomer...');
      final customer = await _firestoreService.addCustomer(
        driverId: driverId,
        name: name,
        phoneNumber: phoneNumber,
      );
      
      // Set the driverId for future operations
      if (_driverId == null) _driverId = driverId;
      
      print('[PROVIDER] Customer added to Firestore with ID: ${customer.id}! Reloading list...');
      await loadCustomers();
      print('[PROVIDER] addCustomer success! Total customers: ${_customers.length}');
      
      _isLoading = false;
      notifyListeners();
      return customer.id;  // Return the customer ID
    } catch (e) {
      _error = 'Failed to add customer: $e';
      print('[PROVIDER] addCustomer error: $_error');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update customer
  Future<bool> updateCustomer(String customerId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateCustomer(customerId, data);
      await loadCustomers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteCustomer(customerId);
      await loadCustomers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
