// import 'package:laravel_echo_null/laravel_echo_null.dart';
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/foundation.dart';

// class RealTimePushService {
//   late Echo echo;
//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotifications() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidInit);

//     await _notificationsPlugin.initialize(initSettings);
//   }

//   Future<void> connectToPrivateChannel({
//     required int passagerId,
//     required String token,
//   }) async {
//     final pusher = PusherChannelsFlutter.getInstance();

//     echo = Echo(
//       broadcaster: 'pusher',
//       client: pusher,
//       options: EchoOptions(
//         host: 'https://ton-backend.com', // 🔁 adapte ici avec ton URL backend
//         key: 'PUSHER_APP_KEY',
//         cluster: 'PUSHER_CLUSTER',
//         encrypted: true,
//         authEndpoint: '/broadcasting/auth',
//         auth: {
//           'headers': {
//             'Authorization': 'Bearer $token',
//             'Accept': 'application/json',
//           },
//         },
//       ),
//     );

//     debugPrint("📡 Connexion à la chaîne privée du passager $passagerId...");

//     echo.private('commande-taxi.$passagerId').listen('.chauffeur.response', (
//       event,
//     ) {
//       debugPrint("📨 Événement reçu: $event");

//       final statut = event['statut'].toString();
//       final message =
//           (statut == '2')
//               ? 'Le chauffeur est en route vers vous 🚖'
//               : 'Le chauffeur a décliné votre demande ❌';

//       _showLocalNotification(
//         title: 'Mise à jour de votre course',
//         body: message,
//       );
//     });
//   }

//   Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'course_channel',
//       'Course Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const notificationDetails = NotificationDetails(android: androidDetails);

//     await _notificationsPlugin.show(0, title, body, notificationDetails);
//   }
// }
