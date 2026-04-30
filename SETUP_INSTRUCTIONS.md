# Setup Instructions

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project"
3. Enter project name: "TaxiTripManager"
4. Click "Continue"
5. Disable Google Analytics (optional) and create project

### Step 2: Register Apps

#### Android App
1. In Firebase Console, click "Add app" and select Android
2. Enter Android package name: `com.example.taxsi_sub`
3. SHA-1 certificate fingerprint:
   ```bash
   # Get your SHA-1 from Android Studio
   # Or run:
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Download `google-services.json`
5. Place in `android/app/` directory

#### iOS App
1. Click "Add app" and select iOS
2. Enter iOS bundle ID: `com.example.taxsiSub`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/` directory (via Xcode)

#### Web App
1. Click "Add app" and select Web
2. Enter app nickname: "Taxi Trip Manager Web"
3. Copy the Firebase config

### Step 3: Configure Flutter Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### Step 4: Update firebase_options.dart

The `flutterfire configure` command should automatically update `lib/firebase_options.dart` with your credentials.

If not, manually update with your Firebase credentials from the Firebase Console.

## Enable Firebase Services

### 1. Authentication

1. Go to Firebase Console > Authentication
2. Click "Get started"
3. Enable "Email/Password" provider
4. Click "Save"

### 2. Firestore Database

1. Go to Firebase Console > Firestore Database
2. Click "Create database"
3. Start in test mode for development
4. Choose a region closer to your location
5. Click "Enable"

### 3. Create Firestore Collections

```
Database Structure:
├── users/
│   └── {userId}/
│       ├── uid: string
│       ├── email: string
│       ├── displayName: string
│       └── createdAt: timestamp
├── customers/
│   └── {customerId}/
│       ├── id: string
│       ├── driverId: string
│       ├── name: string
│       ├── phoneNumber: string
│       ├── createdAt: timestamp
│       ├── lastTripDate: timestamp
│       └── isActive: boolean
├── subscriptions/
│   └── {subscriptionId}/
│       ├── ... (see documentation)
└── trips/
    └── {tripId}/
        ├── ... (see documentation)
```

### 4. Set Firestore Security Rules

Go to Firebase Console > Firestore > Rules

Replace with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users - only users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Customers - drivers can only access their own customers
    match /customers/{customerId} {
      allow read, write: if request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.driverId;
    }

    // Subscriptions
    match /subscriptions/{subscriptionId} {
      allow read, write: if request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.driverId;
    }

    // Trips
    match /trips/{tripId} {
      allow read, write: if request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.driverId;
    }
  }
}
```

## Local Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/taxsi-sub.git
cd taxsi-sub
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Flutter Doctor

```bash
flutter doctor
```

Ensure all checks pass (at least one platform with ✓)

### 4. Run the App

#### Android
```bash
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

## Development Tips

### Hot Reload
- Press `R` in terminal while app is running
- Changes reload instantly

### Hot Restart
- Press `Shift+R` in terminal
- App fully restarts

### Flutter Devtools
```bash
flutter pub global activate devtools
devtools
```

## Deployment

### Android APK/AAB

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS IPA

```bash
# Build iOS
flutter build ios --release
```

### Web

```bash
# Build web
flutter build web --release
```

## Troubleshooting

### Issue: Firebase initialization fails
**Solution:**
1. Verify `google-services.json` is in `android/app/`
2. Verify `GoogleService-Info.plist` is in `ios/Runner/`
3. Run `flutterfire configure` again

### Issue: Firestore connection refused
**Solution:**
1. Check internet connection
2. Verify Firestore is enabled in Firebase Console
3. Check security rules are correct
4. Clear app data and rebuild

### Issue: Authentication not working
**Solution:**
1. Verify Email/Password is enabled
2. Check email format is valid
3. Ensure password is at least 6 characters
4. Check Firebase quota

### Issue: Hot reload not working
**Solution:**
1. Rebuild app: `flutter run`
2. Restart Flutter Devtools
3. Close and run app again

## Environment Variables (Optional)

Create `.env` file in project root:

```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

Load in `main.dart`:
```dart
// Uncomment and modify if using dotenv
// await dotenv.load(fileName: ".env");
```

## Code Quality

### Lint Code

```bash
flutter analyze
```

### Format Code

```bash
dart format lib/
```

### Run Tests

```bash
flutter test
```

## Performance Profiling

```bash
# Run with performance overlay
flutter run --verbose

# Use DevTools profiler
devtools
```

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

**Support:** For issues, please create an issue on GitHub or contact support@taxsimanager.com
