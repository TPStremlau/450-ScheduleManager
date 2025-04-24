import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging and register handlers
  static Future<void> init() async {
    await Firebase.initializeApp();

    await _requestPermission();
    await _saveTokenToFirestore();
    _setupForegroundHandler();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Request notification permission (for Android 13+ and iOS)
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('🔒 User declined or has not accepted permission');
    } else {
      print('✅ Notification permission granted');
    }
  }

  /// Save FCM token to Firestore
  static Future<void> _saveTokenToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));

      print('✅ FCM token saved for user ${user.uid}');
    }
  }

  /// Handle foreground messages
  static void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground push received');
      print('🔔 Title: ${message.notification?.title}');
      print('📝 Body: ${message.notification?.body}');

      // Extract and format event time if available
      String? eventTime = message.data['eventTime'];
      if (eventTime != null) {
        try {
          final dateTime = DateTime.parse(eventTime).toLocal();
          final formatted = DateFormat('MMM d, yyyy h:mm a').format(dateTime);
          print('🕓 Event Time: $formatted');
        } catch (e) {
          print('⚠️ Failed to parse event time: $eventTime');
        }
      }
    });
  }

  /// Handle FCM token refresh
  static void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': newToken});
        print('🔄 FCM token refreshed for user ${user.uid}');
      }
    });
  }
}

/// Must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📦 Background message: ${message.messageId}');
}
