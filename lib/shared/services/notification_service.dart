import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:social_media_app/main.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/layout/home/home_view.dart';

/// Top-level function to handle background messages
/// This must be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

/// Service class to manage all notification-related functionality
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<AccessCredentials> _getAccessToken() async {
    final serviceAccountPath = "important/notification_key.json";

    String serviceAccountJson = await rootBundle.loadString(serviceAccountPath);
    final serviceAccountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountJson);
    final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];
    final client =
        await clientViaServiceAccount(serviceAccountCredentials, scopes);
    return client.credentials;
  }

  Future<void> sendNotification({
    required String receiverToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final credentials = await _getAccessToken();
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/zmlni-6c5f7/messages:send');
    final accessToken = credentials.accessToken.data;
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': {
          'token': receiverToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data?.map((key, value) => MapEntry(key, value.toString())),
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'channel_id': 'high_importance_channel',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
              },
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Notification sent successfully');
    } else {
      debugPrint('Failed to send notification: ${response.body}');
    }
  }

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
    debugPrint(
        'Notification tapped with payload: ${notificationResponse.payload}');
    if (notificationResponse.payload != null) {
      // payload in _showLocalNotification is message.data.toString()
      // This is basic, but we can try to parse if it's JSON-like or just rely on FCM listeners
      // For Local Notifications, we might need a better payload format.
    }
  }

  void navigateToScreen(Map<String, dynamic> data) async {
    if (data['type'] == 'message') {
      final String? senderUid = data['uid'];
      if (senderUid != null) {
        // Fetch user data from Firestore to navigate
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderUid)
            .get();
        if (userDoc.exists) {
          final userModel = UserModel.fromJson(userDoc.data()!);
          navigatorKey.currentState?.pushNamed(
            ChatView.routeName,
            arguments: userModel,
          );
        }
      }
    } else if (data['type'] == 'post') {
      navigatorKey.currentState?.pushNamed(HomeView.routeViewName);
    }
  }

  /// Configure Firebase Cloud Messaging
  Future<void> configureFCM() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set foreground notification presentation options for iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages (when app is in background or terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Message opened from background: ${message.messageId}');
      navigateToScreen(message.data);
    });

    // Handle notification tap when app was terminated
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('Message opened from terminated: ${message.messageId}');
        navigateToScreen(message.data);
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
      final String? token = await _firebaseMessaging.getToken();
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
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
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
