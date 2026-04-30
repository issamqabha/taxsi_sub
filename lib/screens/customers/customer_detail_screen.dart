import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../models/subscription_model.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/app_theme.dart';
import '../../services/notification_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TripProvider _tripProvider;
  late Future<List<SubscriptionModel>> _subscriptionsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tripProvider = TripProvider();
    _tripProvider.initializeCustomer(widget.customer.id);
    
    // Cache the subscriptions future to avoid rebuilds
    _subscriptionsFuture = context.read<SubscriptionProvider>()
        .getSubscriptionsForCustomer(widget.customer.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          widget.customer.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditCustomerDialog();
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(context.translate('edit')),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: AppTheme.errorColor),
                    const SizedBox(width: 8),
                    Text(context.translate('delete')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Subscriptions Reminders Section
            _buildSubscriptionsRemindersSection(context),
            // Subscription Info Card
            _buildSubscriptionCard(context),
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
                    Tab(text: context.translate('trips')),
                    Tab(text: context.translate('weeklyStats')),
                    Tab(text: context.translate('monthlyStats')),
                  ],
                ),
              ),
            ),
            // Tab Content
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTripsTab(context),
                  _buildWeeklyStatsTab(context),
                  _buildMonthlyStatsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'toWork',
            mini: true,
            backgroundColor: AppTheme.primaryColor,
            onPressed: () => _addTrip(TripType.toWork),
            tooltip: context.translate('toWork'),
            child: const Icon(Icons.arrow_upward, color: Colors.black),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'return',
            mini: true,
            backgroundColor: AppTheme.accentColor,
            onPressed: () => _addTrip(TripType.returnTrip),
            tooltip: context.translate('returnTrip'),
            child: const Icon(Icons.arrow_downward, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsRemindersSection(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        return FutureBuilder<List<SubscriptionModel>>(
          future: _subscriptionsFuture,  // Use cached future
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final subscriptions = snapshot.data!;
            return Column(
              children: [
                // Test Notification Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () async {
                      // Show test notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📢 Sending test notification...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Send test notification
                      await NotificationService().showTestNotification();
                    },
                    child: Card(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🔔 Test Notification',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Tap to receive a test notification',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ...subscriptions
                    .map((sub) => _buildSubscriptionReminderCard(context, sub))
                    .toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSubscriptionReminderCard(BuildContext context, SubscriptionModel subscription) {
    final hasReminder = subscription.reminderTime != null;
    final reminderText = hasReminder 
        ? '${subscription.reminderTime!.hour}:${subscription.reminderTime!.minute.toString().padLeft(2, '0')}'
        : 'No reminder';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: hasReminder ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: hasReminder ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subscription.type.displayName} Subscription',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reminder: $reminderText',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasReminder ? AppTheme.primaryColor : AppTheme.textSecondary,
                        fontWeight: hasReminder ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  hasReminder ? Icons.notifications_active : Icons.notifications_none,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                onPressed: () => _showSubscriptionReminderDialog(context, subscription),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        return StreamBuilder<SubscriptionModel?>(
          stream: subscriptionProvider.getSubscriptionStream(widget.customer.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return _buildNoSubscriptionCard(context);
            }

            final subscription = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with type badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.translate('subscriptionType'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              subscription.type.displayName,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Balance with status indicator
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: _getBalanceColor(subscription.currentBalance),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translate('remainingBalance'),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${subscription.currentBalance.toStringAsFixed(2)} JOD',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: _getBalanceColor(subscription.currentBalance),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              context,
                              context.translate('tripsUsed'),
                              '${subscription.tripsUsed}',
                              Icons.directions_car,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatBox(
                              context,
                              'Fee',
                              '${subscription.fee.toStringAsFixed(2)} JOD',
                              Icons.attach_money,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Trip prices
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              context,
                              context.translate('toWork'),
                              subscription.oneWayPrice.toStringAsFixed(2),
                              Icons.arrow_upward,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatBox(
                              context,
                              context.translate('returnTrip'),
                              subscription.returnPrice.toStringAsFixed(2),
                              Icons.arrow_downward,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoSubscriptionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.subscriptions_outlined,
                color: AppTheme.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                context.translate('noSubscription'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to add subscription
                },
                child: Text(context.translate('addSubscription')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance <= 0) {
      return AppTheme.errorColor;
    } else if (balance < 10) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.successColor;
    }
  }

  Widget _buildTripsTab(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tripProvider,
      child: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          return StreamBuilder<List<TripModel>>(
            stream: tripProvider.getTripsStream(widget.customer.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                );
              }

              final trips = snapshot.data!;
              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.route_outlined,
                        color: AppTheme.textSecondary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.translate('noTrips'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return _buildTripCard(context, trip);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    final isToWork = trip.type == TripType.toWork;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isToWork ? AppTheme.primaryColor : AppTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isToWork ? Icons.arrow_upward : Icons.arrow_downward,
                color: isToWork ? Colors.black : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToWork ? context.translate('toWork') : context.translate('returnTrip'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${trip.dateTime.hour}:${trip.dateTime.minute.toString().padLeft(2, '0')} - ${trip.dateTime.day}/${trip.dateTime.month}/${trip.dateTime.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${trip.price.toStringAsFixed(2)} JOD',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 18),
                  onPressed: () => _deleteTrip(trip),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsTab(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tripProvider,
      child: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          final now = DateTime.now();
          final weekNumber = _getWeekNumber(now);
          
          return FutureBuilder<List<TripModel>>(
            future: tripProvider.getWeeklyTrips(weekNumber, now.year),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                );
              }

              final trips = snapshot.data!;
              double totalCost = trips.fold(0, (sum, trip) => sum + trip.price);
              int tripCount = trips.length;

              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_outlined,
                        color: AppTheme.textSecondary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No trips this week',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            context,
                            'Total Trips',
                            '$tripCount',
                            Icons.directions_car,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            context,
                            'Total Cost',
                            '${totalCost.toStringAsFixed(2)} JOD',
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthlyStatsTab(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tripProvider,
      child: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          final now = DateTime.now();
          
          return FutureBuilder<List<TripModel>>(
            future: tripProvider.getMonthlyTrips(now.month, now.year),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                );
              }

              final trips = snapshot.data!;
              double totalCost = trips.fold(0, (sum, trip) => sum + trip.price);
              int tripCount = trips.length;

              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_outlined,
                        color: AppTheme.textSecondary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No trips this month',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            context,
                            'Total Trips',
                            '$tripCount',
                            Icons.directions_car,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            context,
                            'Total Cost',
                            '${totalCost.toStringAsFixed(2)} JOD',
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addTrip(TripType tripType) async {
    final authProvider = context.read<AuthProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    if (authProvider.user == null) return;

    await subscriptionProvider.loadSubscription(widget.customer.id);
    
    final trip = await subscriptionProvider.addTrip(
      customerId: widget.customer.id,
      driverId: authProvider.user!.uid,
      type: tripType,
    );

    if (mounted) {
      if (trip != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('tripAdded')),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              subscriptionProvider.error ?? context.translate('somethingWentWrong'),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(context.translate('deleteCustomer')),
        content: Text(context.translate('deleteCustomerConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final customerProvider = context.read<CustomerProvider>();
              final success = await customerProvider.deleteCustomer(widget.customer.id);
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer deleted successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(customerProvider.error ?? 'Failed to delete customer'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              context.translate('delete'),
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog() {
    final nameController = TextEditingController(text: widget.customer.name);
    final phoneController = TextEditingController(text: widget.customer.phoneNumber ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(context.translate('edit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.translate('customerName'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: context.translate('phoneNumber'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final customerProvider = context.read<CustomerProvider>();
              final success = await customerProvider.updateCustomer(
                widget.customer.id,
                {
                  'name': nameController.text,
                  'phoneNumber': phoneController.text.isEmpty ? null : phoneController.text,
                },
              );
              
              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer updated successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(customerProvider.error ?? 'Failed to update customer'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(context.translate('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip(TripModel trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.translate('delete'),
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _tripProvider.deleteTrip(
        trip.id,
        widget.customer.id,
        trip.price,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Trip deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tripProvider.error ?? 'Failed to delete trip'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showSubscriptionReminderDialog(BuildContext context, SubscriptionModel subscription) {
    DateTime? selectedReminderTime = subscription.reminderTime;
    final subscriptionProvider = context.read<SubscriptionProvider>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text('Set Subscription Reminder'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${subscription.type.displayName} Subscription',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (subscription.reminderTime != null)
                    Column(
                      children: [
                        Text(
                          'Current reminder: ${subscription.reminderTime!.hour}:${subscription.reminderTime!.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: const Text('Set Custom Time'),
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                subscription.reminderTime ?? DateTime.now(),
                              ),
                            );

                            if (pickedTime != null) {
                              setState(() {
                                selectedReminderTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.timer),
                          label: const Text('Every Day at 8:00 AM'),
                          onPressed: () {
                            setState(() {
                              selectedReminderTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                8,
                                0,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.timer),
                          label: const Text('Every Day at 6:00 PM'),
                          onPressed: () {
                            setState(() {
                              selectedReminderTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                18,
                                0,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.timer),
                          label: const Text('Every Day at 9:00 PM'),
                          onPressed: () {
                            setState(() {
                              selectedReminderTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                21,
                                0,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (subscription.reminderTime != null)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.clear),
                            label: const Text('Cancel Reminder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              
                              // Cancel the notification
                              final notificationId = subscription.id.hashCode;
                              await NotificationService().cancelReminder(notificationId);
                              
                              // Remove from Firestore
                              await subscriptionProvider.updateSubscriptionReminder(
                                subscription.id,
                                null,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reminder cancelled'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (selectedReminderTime != null)
                TextButton(
                  onPressed: () async {
                    // Schedule the notification first
                    DateTime reminderDateTime = selectedReminderTime!;
                    
                    // If the selected time is in the past today, schedule for tomorrow
                    if (reminderDateTime.isBefore(DateTime.now())) {
                      reminderDateTime = reminderDateTime.add(const Duration(days: 1));
                    }

                    // Generate unique ID from subscription ID
                    final notificationId = subscription.id.hashCode;
                    
                    await NotificationService().scheduleReminder(
                      id: notificationId,
                      tripId: subscription.id,
                      customerName: widget.customer.name,
                      tripTime: '${subscription.type.displayName} Subscription',
                      reminderDateTime: reminderDateTime,
                    );
                    
                    // Save to Firestore
                    await subscriptionProvider.updateSubscriptionReminder(
                      subscription.id,
                      selectedReminderTime,
                    );

                    // Now close the dialog and show snackbar
                    Navigator.pop(context);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reminder set for ${selectedReminderTime!.hour}:${selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                          ),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                    setState(() {});
                  },
                  child: const Text('Set Reminder'),
                ),
            ],
          );
        },
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    // ISO 8601 week number
    int dayOfYear = int.parse(date.toString().split('-')[2].split(' ')[0]);
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
  }
}
