# Taxi Subscription & Trip Tracker - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. **Prerequisites**
- Flutter SDK (3.9.2+)
- Firebase project
- Android/iOS development environment

### 2. **Clone & Setup**
```bash
git clone <repository-url>
cd taxsi-sub
flutter pub get
```

### 3. **Configure Firebase**
```bash
# Install FlutterFire CLI if not installed
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 4. **Run the App**
```bash
flutter run
```

### 5. **Create Test Account**
- Tap "Sign Up"
- Enter email and password
- Enter driver name
- Start adding customers!

---

## 📱 App Flow

### First Time User
1. **Splash Screen** (2 seconds)
2. **Sign Up/Sign In**
3. **Dashboard** (customer list)
4. **Add Customer** (new customer setup)

### Customer Operations
1. **Tap Customer** → View details
2. **Add Trip** → "To Work" or "Return"
3. **View History** → See all trips
4. **Check Stats** → Weekly/Monthly reports

---

## 🎯 Key Features at a Glance

| Feature | Description |
|---------|-------------|
| 🔐 Auth | Email/password with Firebase |
| 👥 Customers | Add, edit, delete customers |
| 💳 Subscriptions | Weekly/Monthly plans |
| 🚗 Trips | Track to/return trips |
| 📊 Stats | Weekly & monthly reports |
| 🌍 Multi-language | English & Arabic (RTL) |
| 🎨 Dark Theme | Modern UI/UX |

---

## 📁 File Structure Quick Reference

```
Key Files:
├── lib/main.dart ........................ App entry point
├── lib/screens/splash_screen.dart ....... Loading screen
├── lib/screens/auth/ ..................... Sign in/up
├── lib/screens/home/home_screen.dart .... Dashboard
├── lib/screens/customers/ ............... Customer management
├── lib/providers/ ....................... State management
├── lib/services/ ........................ Firebase logic
└── lib/utils/app_theme.dart ............ Theme configuration
```

---

## 🔧 Common Tasks

### Add a New Feature

1. **Create Model** (if needed)
   ```dart
   // lib/models/feature_model.dart
   class FeatureModel {
     // Define properties and methods
   }
   ```

2. **Create Provider** (for state management)
   ```dart
   // lib/providers/feature_provider.dart
   class FeatureProvider extends ChangeNotifier {
     // Implement logic
   }
   ```

3. **Create Screen**
   ```dart
   // lib/screens/feature_screen.dart
   class FeatureScreen extends StatefulWidget {
     // Implement UI
   }
   ```

### Change Theme Color

Edit `lib/utils/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF00BCD4); // Change this
```

### Add Translation

Edit `lib/utils/app_localizations.dart`:
```dart
'en': {
  'newKey': 'English text',
},
'ar': {
  'newKey': 'النص بالعربية',
},
```

---

## 🗄️ Firestore Database Structure

### Users
```json
{
  "uid": "user123",
  "email": "driver@example.com",
  "displayName": "Ahmed",
  "createdAt": "2026-02-23T10:00:00Z"
}
```

### Customers
```json
{
  "id": "customer123",
  "driverId": "user123",
  "name": "Mohammed",
  "phoneNumber": "+962791234567",
  "createdAt": "2026-02-23T10:00:00Z",
  "isActive": true
}
```

### Subscriptions
```json
{
  "id": "sub123",
  "customerId": "customer123",
  "type": "weekly",
  "fee": 10.0,
  "oneWayPrice": 1.5,
  "returnPrice": 1.5,
  "currentBalance": 8.5,
  "tripsUsed": 1
}
```

### Trips
```json
{
  "id": "trip123",
  "customerId": "customer123",
  "driverId": "user123",
  "type": "toWork",
  "price": 1.5,
  "dateTime": "2026-02-23T08:30:00Z",
  "weekNumber": 8,
  "monthNumber": 2,
  "year": 2026
}
```

---

## 🎨 Color Palette

| Purpose | Color | Hex |
|---------|-------|-----|
| Primary | Cyan | #00BCD4 |
| Accent | Orange | #FF6B35 |
| Background | Dark | #121212 |
| Surface | Gray | #1E1E1E |
| Success | Green | #4CAF50 |
| Error | Red | #F44336 |
| Warning | Yellow | #FFC107 |

---

## 📊 UI Components

### Buttons
```dart
// Primary button
ElevatedButton(
  onPressed: () {},
  child: Text('Action'),
)

// Secondary button
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
)
```

### Cards
```dart
Card(
  color: AppTheme.surfaceColor,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: // content
)
```

### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
)
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Firebase init fails | Run `flutterfire configure` |
| Firestore not working | Enable Firestore + check rules |
| Login fails | Check Email/Password enabled |
| Hot reload fails | Rebuild: `flutter run` |
| App crashes | Check `flutter analyze` for errors |

---

## 📚 Documentation Files

- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Full documentation
- **[SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)** - Detailed setup guide
- **[API_REFERENCE.md](API_REFERENCE.md)** - API endpoints

---

## 💡 Tips & Tricks

- Use `ctrl+shift+p` → "Flutter: Run" in VS Code
- `R` key to hot reload changes
- `ctrl+shift+d` for Debug Console
- Use `devtools` for app inspection
- Check `firebase_options.dart` for Firebase config

---

## 🤝 Contributing

1. Create a feature branch
2. Implement changes
3. Test thoroughly
4. Submit pull request

---

## 📞 Support

- **Email:** support@taxsimanager.com
- **Issues:** GitHub Issues
- **Discord:** [Join Community]

---

**Version:** 1.0.0 | **Last Updated:** February 23, 2026
