import 'package:final_project/authentication.dart';
import 'package:final_project/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📲 Foreground notification: ${message.notification?.title}');
    if (message.notification != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder:
            (_) => AlertDialog(
              title: Text(message.notification!.title ?? 'Notification'),
              content: Text(message.notification!.body ?? ''),
            ),
      );
    }
  });

  await FirebaseMessaging.instance
      .requestPermission(); // ask iOS for permission

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📲 Foreground notification: ${message.notification?.title}');
    if (message.notification != null) {
      // Optional: Show a dialog/snackbar/toast
      showDialog(
        context: navigatorKey.currentContext!,
        builder:
            (_) => AlertDialog(
              title: Text(message.notification!.title ?? 'Notification'),
              content: Text(message.notification!.body ?? ''),
            ),
      );
    }
  });
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Auth(),
    );
  }
}
