import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Common
      'appName': 'Taxi Trip Manager',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'back': 'Back',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'confirm': 'Confirm',
      'search': 'Search',

      // Auth
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'signOut': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'dontHaveAccount': 'Don\'t have an account?',
      'alreadyHaveAccount': 'Already have an account?',
      'forgotPassword': 'Forgot Password?',
      'resetPassword': 'Reset Password',
      'invalidEmail': 'Invalid email address',
      'passwordTooShort': 'Password must be at least 6 characters',
      'passwordsDoNotMatch': 'Passwords do not match',
      'emailRequired': 'Email is required',
      'passwordRequired': 'Password is required',
      'nameRequired': 'Name is required',
      'rememberMe': 'Remember me',
      'welcome': 'Welcome back to your dashboard',
      'requireEmail': 'Please enter email and password',

      // Home
      'home': 'Home',
      'dashboard': 'Dashboard',
      'totalCustomers': 'Total Customers',
      'totalTrips': 'Total Trips',
      'totalRevenue': 'Total Revenue',
      'todayTrips': 'Today Trips',
      'recentActivity': 'Recent Activity',
      'recentTransactions': 'Recent Transactions',
      'noData': 'No data available',

      // Customers
      'customers': 'Customers',
      'addCustomer': 'Add Customer',
      'editCustomer': 'Edit Customer',
      'deleteCustomer': 'Delete Customer',
      'customerName': 'Customer Name',
      'phoneNumber': 'Phone Number',
      'customerInfo': 'Customer Information',
      'noCustomers': 'No customers yet',
      'deleteCustomerConfirm': 'Are you sure you want to delete this customer?',
      'addedSuccessfully': 'Added successfully',
      'updatedSuccessfully': 'Updated successfully',
      'deletedSuccessfully': 'Deleted successfully',

      // Subscriptions
      'subscription': 'Subscription',
      'subscriptionType': 'Subscription Type',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'subscriptionFee': 'Subscription Fee',
      'oneWayPrice': 'One Way Price',
      'returnPrice': 'Return Price',
      'currentBalance': 'Current Balance',
      'remainingBalance': 'Remaining Balance',
      'tripsUsed': 'Trips Used',
      'addSubscription': 'Add Subscription',
      'editSubscription': 'Edit Subscription',
      'noSubscription': 'No active subscription',
      'insufficientBalance': 'Insufficient Balance',

      // Trips
      'trips': 'Trips',
      'tripHistory': 'Trip History',
      'addTrip': 'Add Trip',
      'toWork': 'To Work',
      'returnTrip': 'Return Trip',
      'tripPrice': 'Trip Price',
      'tripDate': 'Trip Date',
      'tripTime': 'Trip Time',
      'noTrips': 'No trips recorded',
      'tripAdded': 'Trip added successfully',
      'tripDeleted': 'Trip deleted successfully',

      // Statistics
      'statistics': 'Statistics',
      'weeklyStats': 'Weekly Statistics',
      'monthlyStats': 'Monthly Statistics',
      'tripsCount': 'Trips Count',
      'revenue': 'Revenue',
      'paid': 'Paid',
      'pending': 'Pending',
      'extra': 'Extra Due',

      // Profile
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout?',
      'about': 'About',
      'version': 'Version',
      'support': 'Support',

      // Messages
      'somethingWentWrong': 'Something went wrong',
      'tryAgain': 'Try Again',
      'noInternet': 'No internet connection',
      'offline': 'You are offline',
      'online': 'You are online',
    },
    'ar': {
      // Common
      'appName': 'مدير رحلات التاكسي',
      'ok': 'حسناً',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'close': 'إغلاق',
      'back': 'رجوع',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'confirm': 'تأكيد',
      'search': 'بحث',

      // Auth
      'signIn': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'signOut': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'fullName': 'الاسم الكامل',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'هل لديك حساب بالفعل؟',
      'forgotPassword': 'هل نسيت كلمة المرور؟',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'invalidEmail': 'عنوان بريد إلكتروني غير صالح',
      'passwordTooShort': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'emailRequired': 'البريد الإلكتروني مطلوب',
      'passwordRequired': 'كلمة المرور مطلوبة',
      'nameRequired': 'الاسم مطلوب',
      'rememberMe': 'تذكرني',
      'welcome': 'مرحبا بعودتك إلى لوحة التحكم',
      'requireEmail': 'يرجى إدخال البريد الإلكتروني وكلمة المرور',

      // Home
      'home': 'الرئيسية',
      'dashboard': 'لوحة التحكم',
      'totalCustomers': 'إجمالي العملاء',
      'totalTrips': 'إجمالي الرحلات',
      'totalRevenue': 'إجمالي الإيرادات',
      'todayTrips': 'رحلات اليوم',
      'recentActivity': 'النشاط الأخير',
      'recentTransactions': 'المعاملات الأخيرة',
      'noData': 'لا توجد بيانات متاحة',

      // Customers
      'customers': 'العملاء',
      'addCustomer': 'إضافة عميل',
      'editCustomer': 'تعديل العميل',
      'deleteCustomer': 'حذف العميل',
      'customerName': 'اسم العميل',
      'phoneNumber': 'رقم الهاتف',
      'customerInfo': 'معلومات العميل',
      'noCustomers': 'لا توجد عملاء حتى الآن',
      'deleteCustomerConfirm': 'هل أنت متأكد أنك تريد حذف هذا العميل؟',
      'addedSuccessfully': 'تمت الإضافة بنجاح',
      'updatedSuccessfully': 'تم التحديث بنجاح',
      'deletedSuccessfully': 'تم الحذف بنجاح',

      // Subscriptions
      'subscription': 'الاشتراك',
      'subscriptionType': 'نوع الاشتراك',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'subscriptionFee': 'رسوم الاشتراك',
      'oneWayPrice': 'سعر الذهاب',
      'returnPrice': 'سعر العودة',
      'currentBalance': 'الرصيد الحالي',
      'remainingBalance': 'الرصيد المتبقي',
      'tripsUsed': 'الرحلات المستخدمة',
      'addSubscription': 'إضافة اشتراك',
      'editSubscription': 'تعديل الاشتراك',
      'noSubscription': 'لا يوجد اشتراك نشط',
      'insufficientBalance': 'رصيد غير كافي',

      // Trips
      'trips': 'الرحلات',
      'tripHistory': 'سجل الرحلات',
      'addTrip': 'إضافة رحلة',
      'toWork': 'ذهاب للعمل',
      'returnTrip': 'عودة',
      'tripPrice': 'سعر الرحلة',
      'tripDate': 'تاريخ الرحلة',
      'tripTime': 'وقت الرحلة',
      'noTrips': 'لم يتم تسجيل رحلات',
      'tripAdded': 'تمت إضافة الرحلة بنجاح',
      'tripDeleted': 'تم حذف الرحلة بنجاح',

      // Statistics
      'statistics': 'الإحصائيات',
      'weeklyStats': 'الإحصائيات الأسبوعية',
      'monthlyStats': 'الإحصائيات الشهرية',
      'tripsCount': 'عدد الرحلات',
      'revenue': 'الإيرادات',
      'paid': 'مدفوع',
      'pending': 'قيد الانتظار',
      'extra': 'مستحق إضافي',

      // Profile
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'theme': 'المظهر',
      'logout': 'تسجيل الخروج',
      'logoutConfirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'about': 'حول',
      'version': 'الإصدار',
      'support': 'الدعم',

      // Messages
      'somethingWentWrong': 'حدث خطأ ما',
      'tryAgain': 'حاول مرة أخرى',
      'noInternet': 'لا توجد اتصالات إنترنت',
      'offline': 'أنت غير متصل',
      'online': 'أنت متصل',
    },
  };

  String translate(String key) {
    String languageCode = locale.languageCode;
    if (!_translations.containsKey(languageCode)) {
      languageCode = 'en';
    }
    return _translations[languageCode]?[key] ?? key;
  }

  static final LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}

extension AppLocalizationsExt on BuildContext {
  AppLocalizations get i18n => AppLocalizations.of(this)!;

  String translate(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
