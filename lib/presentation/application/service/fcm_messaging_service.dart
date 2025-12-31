// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class FirebaseMessagingService {
//   static final _firebaseMessaging = FirebaseMessaging.instance;
//   static final _localNotifications = FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     // 🔐 iOS uchun permission so‘rash
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     // 💡 Android & iOS uchun local notification init
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _localNotifications.initialize(initSettings);
//
//     // 📬 Foregroundda kelgan notification
//     FirebaseMessaging.onMessage.listen(_handleMessage);
//
//     // 📲 Backgrounddan ochilganda
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification clicked: ${message.notification?.title}');
//     });
//
//     // 💤 Terminated holatdan ochilganda
//     RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleMessage(initialMessage);
//     }
//   }
//
//   static void _handleMessage(RemoteMessage message) {
//     final notification = message.notification;
//     final android = message.notification?.android;
//
//     if (notification != null) {
//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: android != null
//               ? AndroidNotificationDetails(
//             'fcm_default_channel',
//             'FCM Notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//           )
//               : null,
//           iOS: const DarwinNotificationDetails(),
//         ),
//       );
//     }
//   }
// }