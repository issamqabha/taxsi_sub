import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../models/subscription_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/app_theme.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _feeController;
  late TextEditingController _oneWayPriceController;
  late TextEditingController _returnPriceController;

  SubscriptionType _subscriptionType = SubscriptionType.weekly;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _feeController = TextEditingController();
    _oneWayPriceController = TextEditingController();
    _returnPriceController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    _oneWayPriceController.dispose();
    _returnPriceController.dispose();
    super.dispose();
  }

  Future<void> _addCustomerAndSubscription() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final fee = double.tryParse(_feeController.text) ?? 0;
    final oneWayPrice = double.tryParse(_oneWayPriceController.text) ?? 0;
    final returnPrice = double.tryParse(_returnPriceController.text) ?? 0;

    // Validation
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('nameRequired'))),
      );
      return;
    }

    if (fee <= 0 || oneWayPrice <= 0 || returnPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid prices')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('[ADD_CUSTOMER] Starting customer creation with subscription...');
      final customerProvider = context.read<CustomerProvider>();
      final subscriptionProvider = context.read<SubscriptionProvider>();
      
      // Step 1: Create customer
      print('[ADD_CUSTOMER] Step 1: Creating customer with name=$name, phone=$phone');
      final customerId = await customerProvider.addCustomer(
        name: name,
        phoneNumber: phone.isNotEmpty ? phone : null,
      );

      if (!mounted) return;

      if (customerId == null) {
        setState(() => _isLoading = false);
        print('[ADD_CUSTOMER] Customer creation failed: ${customerProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customerProvider.error ?? 'Failed to create customer',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      print('[ADD_CUSTOMER] Step 2: Customer created with ID=$customerId. Creating subscription...');
      
      // Step 2: Create subscription for the customer
      final subSuccess = await subscriptionProvider.addSubscription(
        customerId: customerId,
        type: _subscriptionType,
        fee: fee,
        oneWayPrice: oneWayPrice,
        returnPrice: returnPrice,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (subSuccess) {
        print('[ADD_CUSTOMER] Customer and subscription created successfully!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer and subscription created successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // Wait a moment then pop
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context);
        }
      } else {
        print('[ADD_CUSTOMER] Subscription creation failed: ${subscriptionProvider.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Customer created but subscription failed: ${subscriptionProvider.error}',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      print('[ADD_CUSTOMER] Exception: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          context.translate('addCustomer'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 3),
                    insets: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  tabs: [
                    Tab(text: context.translate('customerInfo')),
                    Tab(text: context.translate('subscription')),
                  ],
                ),
              ),
            ),
            // Tab Content
            SizedBox(
              height: 450,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCustomerInfoTab(context),
                  _buildSubscriptionTab(context),
                ],
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addCustomerAndSubscription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                          : Text(
                        context.translate('save'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.translate('cancel'),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name
            Text(
              context.translate('customerName'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: context.translate('customerName'),
                prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Phone Number
            Text(
              context.translate('phoneNumber'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: context.translate('phoneNumber'),
                prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Type
            Text(
              context.translate('subscriptionType'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _subscriptionType = SubscriptionType.weekly);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _subscriptionType == SubscriptionType.weekly
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            context.translate('weekly'),
                            style: TextStyle(
                              color: _subscriptionType == SubscriptionType.weekly
                                  ? Colors.black
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _subscriptionType = SubscriptionType.monthly);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _subscriptionType == SubscriptionType.monthly
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            context.translate('monthly'),
                            style: TextStyle(
                              color: _subscriptionType == SubscriptionType.monthly
                                  ? Colors.black
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Subscription Fee
            Text(
              context.translate('subscriptionFee'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feeController,
              decoration: InputDecoration(
                hintText: '10.00',
                prefixIcon: const Icon(Icons.attach_money, color: AppTheme.primaryColor),
                suffixText: 'JOD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            // One Way Price
            Text(
              context.translate('oneWayPrice'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _oneWayPriceController,
              decoration: InputDecoration(
                hintText: '1.50',
                prefixIcon: const Icon(Icons.arrow_upward, color: AppTheme.primaryColor),
                suffixText: 'JOD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            // Return Price
            Text(
              context.translate('returnPrice'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _returnPriceController,
              decoration: InputDecoration(
                hintText: '1.50',
                prefixIcon: const Icon(Icons.arrow_downward, color: AppTheme.primaryColor),
                suffixText: 'JOD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
    );
  }
}
