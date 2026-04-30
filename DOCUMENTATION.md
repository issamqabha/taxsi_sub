# Taxi Subscription & Trip Tracker Mobile App

A professional Flutter mobile application designed for taxi drivers to manage customer subscriptions, track trips, and maintain financial records with a modern dark theme UI and Arabic language support.

## Features

### 🔐 Authentication
- **Email-based Sign In/Sign Up** with Firebase Authentication
- Multiple taxi driver accounts support
- Secure password management
- Profile management

### 📊 Dashboard
- **Modern Dark Theme UI** with minimalistic and elegant design
- Animated transitions and micro-interactions
- Real-time customer list with subscription status
- Quick access to customer details
- Display of:
  - Customer name
  - Subscription type (weekly/monthly)
  - Remaining balance
  - Number of trips used
  - Last trip date

### 👥 Customer Management
- **Add new customers** with:
  - Name and phone number (optional)
  - Subscription fee configuration
  - Trip pricing (one-way and return prices)
- **Edit** customer profiles
- **Delete** customer records
- Real-time customer updates

### 🚗 Trip Tracking
- **Trip logging** for each customer:
  - "Trip to work" button for outbound trips
  - "Return trip" button for inbound trips
  - Automatic balance deduction
  - Support for multiple trips per day
- **Real-time balance updates**
- **Trip history** with timestamps and details

### 📅 Subscription Management
- **Weekly and Monthly** subscription options
- **Flexible pricing:**
  - Subscription fee
  - One-way trip price
  - Return trip price
- **Balance tracking** with status indicators:
  - ✅ Paid (sufficient balance)
  - ⚠️ Low balance (< 10 JOD)
  - ❌ Insufficient balance (deduction blocked)

### 📈 Weekly & Monthly Summary
- Display total trips (to work/return)
- Show remaining balance
- Status indicators for payment status
- Trip count by type

### 📝 History & Reports
- Comprehensive trip log
- Weekly and monthly statistics
- Charts for visual trip vs. balance analysis
- Export functionality (future enhancement)

### 🌐 Internationalization
- **Arabic language support** with RTL layout
- **English** as default language
- Easy language switching

### 🎨 UI/UX Excellence
- **Consistent Dark Theme** - modern and sleek
- **Smooth Animations** - professional transitions
- **Large Buttons** - optimized for driving context
- **Responsive Design** - works on phones and tablets
- **Accessible** - clear typography and color contrast

## Tech Stack

- **Frontend:** Flutter 3.9.2+
- **State Management:** Provider
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
- **Design:** Material Design 3
- **Localization:** intl + Custom localization
- **Charts:** fl_chart
- **Fonts:** Google Fonts (Poppins)

## Project Structure

```
lib/
├── models/                 # Data models
│   ├── user_model.dart
│   ├── customer_model.dart
│   ├── subscription_model.dart
│   └── trip_model.dart
├── services/              # Business logic & Firebase
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/             # State management (Provider)
│   ├── auth_provider.dart
│   ├── customer_provider.dart
│   ├── subscription_provider.dart
│   └── trip_provider.dart
├── screens/              # UI Screens
│   ├── splash_screen.dart
│   ├── auth/             # Authentication screens
│   │   ├── sign_in_screen.dart
│   │   └── sign_up_screen.dart
│   ├── home/             # Main dashboard
│   │   └── home_screen.dart
│   ├── customers/        # Customer management
│   │   ├── customer_detail_screen.dart
│   │   └── add_customer_screen.dart
│   └── profile/          # User profile & settings
│       └── profile_screen.dart
├── utils/                # Utilities
│   ├── app_theme.dart
│   ├── app_localizations.dart
│   ├── app_constants.dart
│   └── validators.dart
├── widgets/              # Reusable widgets
│   └── custom_widgets.dart
├── main.dart             # Entry point
└── firebase_options.dart # Firebase configuration
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or later)
- Android Studio or Xcode for mobile development
- Firebase project setup
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/taxsi-sub.git
   cd taxsi-sub
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective platform directories
   - Run FlutterFire CLI:
     ```bash
     flutterfire configure
     ```
   - Update `lib/firebase_options.dart` with your credentials

4. **Enable Firebase Services:**
   - Enable Authentication (Email/Password)
   - Create Firestore Database in test mode (or configure rules)
   - Set up the following collections:
     - `users` - User profiles
     - `customers` - Customer data
     - `subscriptions` - Subscription details
     - `trips` - Trip records

5. **Run the app:**
   ```bash
   flutter run
   ```

### Firestore Database Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Customers collection
    match /customers/{customerId} {
      allow read, write: if request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.driverId;
    }

    // Subscriptions collection
    match /subscriptions/{subscriptionId} {
      allow read, write: if request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.driverId;
    }

    // Trips collection
    match /trips/{tripId} {
      allow read, write: if request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.driverId;
    }
  }
}
```

## Usage Guide

### Sign Up / Sign In
1. Launch the app
2. Create a new account with email and password or sign in
3. Fill in your driver name
4. Agree to terms & conditions

### Add Customer
1. Tap the "+" button on the dashboard
2. Enter customer name and phone number
3. Switch to "Subscription" tab
4. Select subscription type (weekly/monthly)
5. Set subscription fee and trip prices
6. Tap "Save"

### Log Trip
1. Select a customer from the dashboard
2. Tap either:
   - Up arrow for "To Work" trip
   - Down arrow for "Return" trip
3. Trip is immediately recorded and balance updated
4. View trip history in the "Trips" tab

### View Statistics
1. Open a customer's profile
2. Switch to "Weekly Stats" or "Monthly Stats" tab
3. View trip counts and revenue

### Manage Profile
1. Tap settings icon
2. View or update driver information
3. Change language/theme settings
4. Sign out

## API Endpoints (Firestore Collections)

### Users Collection
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp"
}
```

### Customers Collection
```json
{
  "id": "string",
  "driverId": "string",
  "name": "string",
  "phoneNumber": "string | null",
  "createdAt": "timestamp",
  "lastTripDate": "timestamp | null",
  "isActive": "boolean"
}
```

### Subscriptions Collection
```json
{
  "id": "string",
  "customerId": "string",
  "type": "weekly | monthly",
  "fee": "double",
  "oneWayPrice": "double",
  "returnPrice": "double",
  "currentBalance": "double",
  "tripsUsed": "int",
  "startDate": "timestamp",
  "endDate": "timestamp | null",
  "isPaid": "boolean"
}
```

### Trips Collection
```json
{
  "id": "string",
  "customerId": "string",
  "driverId": "string",
  "type": "toWork | returnTrip",
  "price": "double",
  "dateTime": "timestamp",
  "notes": "string | null",
  "weekNumber": "int",
  "monthNumber": "int",
  "year": "int"
}
```

## Localization

The app supports both English and Arabic. To add more languages, update `AppLocalizations` in `lib/utils/app_localizations.dart`:

```dart
static Map<String, Map<String, String>> _translations = {
  'en': { /* English translations */ },
  'ar': { /* Arabic translations */ },
  'fr': { /* French translations - add here */ },
};
```

## Customization

### Theme Colors
Edit `lib/utils/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF00BCD4);
static const Color accentColor = Color(0xFFFF6B35);
// ... more colors
```

### App Constants
Update `lib/utils/app_constants.dart` for:
- Padding/spacing values
- Animation durations
- Validation patterns

## Debugging

### Common Issues

1. **Firebase initialization fails:**
   - Run `flutterfire configure` again
   - Check Firebase project ID in `firebase_options.dart`

2. **Firestore connection refused:**
   - Enable Firestore in Firebase Console
   - Update security rules
   - Check internet connection

3. **Authentication fails:**
   - Verify email/password format
   - Enable Email/Password authentication in Firebase
   - Check user account exists

### Logs
View Firebase logs:
```bash
flutter logs
```

## Testing

Run tests with:
```bash
flutter test
```

(Test files should be added in `test/` directory)

## Performance Optimization

- Real-time updates using Firebase Streams
- Lazy loading for trip history
- Provider for efficient state management
- Image caching for profile pictures
- Optimized Firestore queries with indexes

## Security

- Firebase Authentication for secure login
- Firestore security rules for data access control
- No sensitive data stored locally
- HTTPS for all communications
- Input validation and sanitization

## Future Enhancements

- 📱 Push notifications for reminders
- 📊 Advanced analytics and charts
- 💳 Payment gateway integration
- 📧 Email receipts for transactions
- 🗺️ GPS integration for trip tracking
- 🔔 In-app notifications
- 📱 SMS notifications
- 🌙 Multiple theme options
- ⚡ Offline mode support
- 🔄 Data sync when online
- 📱 Android Wear support

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email: support@taxsimanager.com
Or visit: https://www.taxsimanager.com/support

## Authors

- **Your Name** - Initial work

## Acknowledgments

- Flutter team for amazing framework
- Firebase team for backend services
- Google Fonts for typography
- Material Design for design guidelines

---

**Version:** 1.0.0
**Last Updated:** February 23, 2026
**Status:** ✅ Production Ready
