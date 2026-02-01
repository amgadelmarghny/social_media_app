import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Top-level function to handle background messages
/// This must be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}

/// Service class to manage all notification-related functionality
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications with Android and iOS settings
  Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS initialization settings
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel for high importance
    await _createNotificationChannel();
  }

  /// Create Android notification channel with high importance
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      description: 'This channel is used for important notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    // TODO: Navigate to specific screen based on payload
    // You can parse the payload and use Navigator to open specific screens
  }

  /// Configure Firebase Cloud Messaging
  Future<void> configureFCM() async {
    // Request permission for iOS
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set foreground notification presentation options for iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages (when app is in background or terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification tap when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });

    // Setup token refresh listener
    setupTokenRefreshListener();
  }

  /// Handle foreground messages by showing local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');

    // Show local notification when app is in foreground
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle message opened from background state
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened from background: ${message.messageId}');
    // TODO: Navigate to specific screen based on message data
    // Example: if (message.data['type'] == 'chat') { navigate to chat }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // Must match the channel ID created
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Save FCM token to Firestore
  Future<void> saveFCMToken([String? userId]) async {
    try {
      // Get current user ID
      final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        debugPrint('No user logged in, cannot save FCM token');
        return;
      }

      // Get FCM token
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('Failed to get FCM token');
        return;
      }

      debugPrint('FCM Token: $token');

      // Save token to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM token saved successfully to Firestore');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Setup listener for FCM token refresh
  void setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed: $newToken');

      // Auto-save the new token to Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'fcmToken': newToken,
            'tokenUpdatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('New FCM token auto-saved to Firestore');
        } catch (e) {
          debugPrint('Error saving refreshed token: $e');
        }
      }
    });
  }
}
