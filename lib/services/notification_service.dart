import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _permissionsRequested = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      await _requestPermissions();

      print('✅ Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    try {
      // Request Android permissions
      final androidImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        // Create notification channel for Android
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'trip_reminder_channel',
            'Trip Reminders',
            description: 'Notifications for scheduled trips and subscriptions',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

        print('📢 Android notification channel created');
      }

      // Request iOS permissions
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      print('✅ Permissions requested');
    } catch (e) {
      print('⚠️ Error requesting permissions: $e');
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String tripId,
    required String customerName,
    required String tripTime,
    required DateTime reminderDateTime,
  }) async {
    try {
      // First, request permission
      bool hasPermission = await _requestNotificationPermission();
      
      if (!hasPermission) {
        print('❌ Notification permission not granted - reminder not scheduled');
        return;
      }

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'trip_reminder_channel',
        'Trip Reminders',
        channelDescription: 'Notifications for scheduled trips and subscriptions',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      // Convert to local timezone
      final localDateTime = tz.TZDateTime.from(reminderDateTime, tz.local);
      
      print('⏰ Scheduling reminder:');
      print('   ID: $id');
      print('   Customer: $customerName');
      print('   Trip Time: $tripTime');
      print('   Reminder DateTime: $reminderDateTime');
      print('   Local DateTime: $localDateTime');
      print('   Current DateTime: ${DateTime.now()}');

      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '🔔 Trip Reminder',
        'Upcoming trip for $customerName at $tripTime',
        localDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      print('✅ Reminder scheduled successfully for trip $tripId');
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
    }
  }

  Future<void> showTestNotification() async {
    try {
      // First, request permission on Android 13+
      bool hasPermission = await _requestNotificationPermission();
      
      if (!hasPermission) {
        print('❌ Notification permission not granted');
        return;
      }

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'trip_reminder_channel',
        'Trip Reminders',
        channelDescription: 'Test notification',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        999,
        '🔔 Test Notification',
        'This is a test notification to verify the system is working',
        notificationDetails,
      );

      print('✅ Test notification shown');
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }

  Future<bool> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      print('📱 Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('⚠️ Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('✅ Reminder cancelled for ID: $id');
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('✅ All reminders cancelled');
    } catch (e) {
      print('❌ Error cancelling all reminders: $e');
    }
  }

  void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    print('🔔 Notification tapped: ${notificationResponse.actionId}');
  }
}
