# API Reference

## Services Overview

All backend communication is handled through two main services:

### 1. AuthService
Manages user authentication with Firebase Auth

### 2. FirestoreService  
Handles all Firestore database operations

---

## AuthService API

### Methods

#### `Future<(UserModel?, String?)> signUp()`
Creates a new user account.

**Parameters:**
- `email` (String) - User email
- `password` (String) - User password
- `displayName` (String) - Driver name

**Returns:**
- **Success:** `(UserModel, null)` - User object
- **Error:** `(null, String)` - Error message

**Example:**
```dart
final (user, error) = await authService.signUp(
  email: 'driver@example.com',
  password: 'password123',
  displayName: 'Ahmed',
);

if (user != null) {
  print('User created: ${user.displayName}');
} else {
  print('Error: $error');
}
```

#### `Future<(UserModel?, String?)> signIn()`
Signs in an existing user.

**Parameters:**
- `email` (String) - User email
- `password` (String) - User password

**Returns:**
- **Success:** `(UserModel, null)` - User object
- **Error:** `(null, String)` - Error message

#### `Future<void> signOut()`
Signs out the current user.

#### `Future<void> sendPasswordResetEmail()`
Sends password reset email.

**Parameters:**
- `email` (String) - User email

#### `Future<UserModel?> getUserData()`
Retrieves user data from Firestore.

**Parameters:**
- `uid` (String) - User ID

**Returns:**
- `UserModel` - User object or null

#### `Future<void> updateDisplayName()`
Updates user display name.

**Parameters:**
- `displayName` (String) - New name

#### `Future<void> deleteAccount()`
Deletes user account and data.

---

## FirestoreService API

### Customer Operations

#### `Future<CustomerModel> addCustomer()`
Adds a new customer.

**Parameters:**
- `driverId` (String) - Driver ID
- `name` (String) - Customer name
- `phoneNumber` (String?) - Optional phone

**Returns:**
- `CustomerModel` - Created customer

**Example:**
```dart
final customer = await firestoreService.addCustomer(
  driverId: 'user123',
  name: 'Mohammed',
  phoneNumber: '+962791234567',
);
```

#### `Future<List<CustomerModel>> getCustomers()`
Retrieves all customers for a driver.

**Parameters:**
- `driverId` (String) - Driver ID

**Returns:**
- `List<CustomerModel>` - Customer list

#### `Stream<List<CustomerModel>> getCustomersStream()`
Real-time stream of customers.

**Parameters:**
- `driverId` (String) - Driver ID

**Returns:**
- `Stream<List<CustomerModel>>` - Real-time updates

**Example:**
```dart
firestoreService.getCustomersStream(driverId).listen((customers) {
  print('Customers: ${customers.length}');
});
```

#### `Future<void> updateCustomer()`
Updates customer information.

**Parameters:**
- `customerId` (String) - Customer ID
- `data` (Map<String, dynamic>) - Fields to update

**Example:**
```dart
await firestoreService.updateCustomer(
  'customer123',
  {'isActive': false, 'name': 'New Name'},
);
```

#### `Future<void> deleteCustomer()`
Deletes a customer and related data.

**Parameters:**
- `customerId` (String) - Customer ID

---

### Subscription Operations

#### `Future<SubscriptionModel> addSubscription()`
Creates a new subscription.

**Parameters:**
- `customerId` (String) - Customer ID
- `type` (SubscriptionType) - weekly or monthly
- `fee` (double) - Subscription fee
- `oneWayPrice` (double) - One-way trip price
- `returnPrice` (double) - Return trip price

**Returns:**
- `SubscriptionModel` - Created subscription

**Example:**
```dart
final subscription = await firestoreService.addSubscription(
  customerId: 'customer123',
  type: SubscriptionType.weekly,
  fee: 10.0,
  oneWayPrice: 1.5,
  returnPrice: 1.5,
);
```

#### `Future<SubscriptionModel?> getSubscription()`
Gets active subscription for customer.

**Parameters:**
- `customerId` (String) - Customer ID

**Returns:**
- `SubscriptionModel?` - Current subscription or null

#### `Stream<SubscriptionModel?> getSubscriptionStream()`
Real-time subscription updates.

**Parameters:**
- `customerId` (String) - Customer ID

**Returns:**
- `Stream<SubscriptionModel?>` - Real-time updates

#### `Future<void> updateSubscription()`
Updates subscription.

**Parameters:**
- `subscriptionId` (String) - Subscription ID
- `data` (Map<String, dynamic>) - Fields to update

**Example:**
```dart
await firestoreService.updateSubscription(
  'sub123',
  {
    'currentBalance': 5.0,
    'tripsUsed': 3,
  },
);
```

---

### Trip Operations

#### `Future<TripModel> addTrip()`
Records a new trip.

**Parameters:**
- `customerId` (String) - Customer ID
- `driverId` (String) - Driver ID
- `type` (TripType) - toWork or returnTrip
- `price` (double) - Trip price

**Returns:**
- `TripModel` - Created trip

**Throws:**
- `Exception` - If no active subscription

**Example:**
```dart
final trip = await firestoreService.addTrip(
  customerId: 'customer123',
  driverId: 'user123',
  type: TripType.toWork,
  price: 1.5,
);
```

#### `Future<List<TripModel>> getTrips()`
Gets all trips for customer.

**Parameters:**
- `customerId` (String) - Customer ID

**Returns:**
- `List<TripModel>` - Trips list, newest first

#### `Stream<List<TripModel>> getTripsStream()`
Real-time trips updates.

**Parameters:**
- `customerId` (String) - Customer ID

**Returns:**
- `Stream<List<TripModel>>` - Real-time updates

#### `Future<List<TripModel>> getWeeklyTrips()`
Gets trips for specific week.

**Parameters:**
- `customerId` (String) - Customer ID
- `weekNumber` (int) - Week number (1-52)
- `year` (int) - Year

**Returns:**
- `List<TripModel>` - Weekly trips

#### `Future<List<TripModel>> getMonthlyTrips()`
Gets trips for specific month.

**Parameters:**
- `customerId` (String) - Customer ID
- `monthNumber` (int) - Month (1-12)
- `year` (int) - Year

**Returns:**
- `List<TripModel>` - Monthly trips

#### `Future<void> deleteTrip()`
Deletes a trip and refunds balance.

**Parameters:**
- `tripId` (String) - Trip ID
- `subscriptionId` (String) - Subscription ID
- `tripPrice` (double) - Price to refund

**Example:**
```dart
await firestoreService.deleteTrip(
  'trip123',
  'sub123',
  1.5,
);
```

---

### Statistics

#### `Future<Map<String, dynamic>> getDriverStatistics()`
Gets driver statistics.

**Parameters:**
- `driverId` (String) - Driver ID

**Returns:**
```dart
{
  'totalCustomers': 15,
  'totalTrips': 342,
  'totalRevenue': 513.0,
  'todayTrips': 12,
}
```

---

## Provider APIs

### AuthProvider

Methods mirror AuthService with additional state management.

**Properties:**
- `user` (UserModel?) - Current user
- `isLoading` (bool) - Loading state
- `error` (String?) - Error message
- `isAuthenticated` (bool) - Auth status

### CustomerProvider

**Methods:**
- `loadCustomers()` - Load customer list
- `addCustomer()` - Add new customer
- `updateCustomer()` - Update customer
- `deleteCustomer()` - Delete customer
- `getCustomersStream()` - Get real-time updates
- `clearError()` - Clear error message

**Properties:**
- `customers` (List<CustomerModel>) - Customer list
- `isLoading` (bool)
- `error` (String?)

### SubscriptionProvider

**Methods:**
- `loadSubscription()` - Load subscription
- `addSubscription()` - Create subscription
- `updateSubscription()` - Update subscription
- `addTrip()` - Add trip and deduct balance
- `getSubscriptionStream()` - Real-time updates
- `clearError()` - Clear error

**Properties:**
- `isLoading` (bool)
- `error` (String?)

### TripProvider

**Methods:**
- `loadTrips()` - Load all trips
- `getWeeklyTrips()` - Get weekly trips
- `getMonthlyTrips()` - Get monthly trips
- `deleteTrip()` - Delete trip
- `getTodayTripsCount()` - Today's trip count
- `getWeeklyTripsCounts()` - Weekly count by type
- `getMonthlyRevenue()` - Monthly revenue
- `getTripsStream()` - Real-time updates
- `clearError()` - Clear error

**Properties:**
- `trips` (List<TripModel>)
- `isLoading` (bool)
- `error` (String?)

---

## Error Handling

All methods return errors or throw exceptions. Handle appropriately:

```dart
try {
  final customer = await customerProvider.addCustomer(
    name: 'Ahmed',
    phoneNumber: '+962791234567',
  );
} catch (e) {
  print('Error: $e');
}

// Or check error property
if (customerProvider.error != null) {
  print('Error: ${customerProvider.error}');
}
```

---

## Real-Time Updates

Use Streams for live data:

```dart
// Listen to customer changes
customerProvider.getCustomersStream().listen((customers) {
  print('Customers updated: ${customers.length}');
});

// In widgets, use StreamBuilder
StreamBuilder<List<CustomerModel>>(
  stream: customerProvider.getCustomersStream(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView(
        children: snapshot.data!
            .map((c) => ListTile(title: Text(c.name)))
            .toList(),
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

## Pagination & Querying

Future enhancements for pagination:

```dart
// Planned for v2.0
Future<List<CustomerModel>> getCustomersPage({
  required int page,
  required int pageSize,
});

// Planned for v2.0
Future<List<TripModel>> searchTrips({
  required String customerId,
  required DateTime from,
  required DateTime to,
});
```

---

## Rate Limiting

Firestore has quotas:
- 50,000 reads/day (free tier)
- 20,000 writes/day (free tier)
- 1 write per second per document

Optimize queries to stay within limits.

---

## Best Practices

1. **Use Streams for real-time data**
2. **Cache user data locally when possible**
3. **Batch Firestore operations**
4. **Add indexes for complex queries**
5. **Handle errors gracefully**
6. **Test with actual Firebase project**

---

**API Version:** 1.0.0 | **Last Updated:** February 23, 2026
