import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Recherche/SearchLocation.dart';

class NotificationService {
  static Future<void> finishedSoundNotification() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(AssetSource('sounds/notification1.mp3'));
  }

  static Future<void> paddingRideSaundNotification() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(AssetSource('sounds/notification.mp3'));
  }

  static Future<void> acceptingRideSaundNotification() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(AssetSource('sounds/notification2.mp3'));
  }

  /*
  *
  *===================================
  * pour le push notification
  *===================================
  */
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  // Instance du plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialisation (à appeler au démarrage de l'app)
  // static Future<void> initialize() async {
  //   const AndroidInitializationSettings androidSettings =
  //       AndroidInitializationSettings('@mipmap/ic_launcher'); // Icône de l'app

  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(android: androidSettings);

  //   await _notificationsPlugin.initialize(initializationSettings);
  // }

  static const InitializationSettings _initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  static Future<void> initialize() async {
    await _notificationsPlugin.initialize(
      _initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationClick(response.payload);
      },
    );
  }

  static void configureActionHandlers() {
    _notificationsPlugin.initialize(
      _initSettings,
      onDidReceiveBackgroundNotificationResponse: (response) {
        _handleAction(response);
      },
    );
  }

  static void _handleNotificationClick(String? payload) async {
    if (payload == null) return;

    final data = jsonDecode(payload);

    switch (data['type']) {
      case 'ride_accepted':
        // navigatorKey.currentState?.pushNamed(
        //   '/ride-details',
        //   arguments: {'rideId': data['ride_id']},
        // );

        navigatorKey.currentState?.push(
          AnimatedPageRoute(page: SearchLocation()),
        );

        break;
      case 'ride_request':
        // Le chauffeur a cliqué (géré par les actions)
        // SearchLocationMap pour chauffeur
        navigatorKey.currentState?.push(
          AnimatedPageRoute(page: SearchLocation()),
        );
        break;
    }
  }

  // Méthode pour afficher une notification simple
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id', // ID du canal (doit être unique)
          'Notifications', // Nom du canal (visible dans les paramètres)
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0, // ID de la notification (unique pour chaque notification)
      title,
      body,
      details,
    );
  }

  /*
  *
  *============================================
  *pour les notifications avance
  *============================================ 
  *
  */
  //pour le chauffeur
  static Future<void> showDriverNotification({
    required String passengerName,
    required String pickupAddress,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'driver_channel',
          'Demandes de course',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
          actions: [
            AndroidNotificationAction(
              'accept_action',
              'Accepter',
              showsUserInterface: true,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'reject_action',
              'Refuser',
              cancelNotification: true,
            ),
          ],
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode, // ID unique basé sur l'ID de course
      'Nouvelle demande de course',
      '$passengerName à $pickupAddress',
      details,
      payload: jsonEncode({
        'type': 'ride_request',
        'ride_id': rideId,
        'passenger_name': passengerName,
      }),
    );
  }

  static void _handleAction(NotificationResponse response) async {
    final payload = jsonDecode(response.payload ?? '{}');

    if (response.actionId == 'accept_action') {
      // 1. Accepter la course dans la base de données et l'appel de l'api
      // await RideService.acceptRide(payload['ride_id']);

      // 2. Envoyer notification au passager
      showRideAcceptedNotification(
        rideId: payload['ride_id'],
        driverName: 'Votre nom',
        carDetails: 'Votre véhicule',
      );

      // 3. Rediriger vers l'écran de course
      // Navigator.of(context).pushNamed('/active-ride');
    } else if (response.actionId == 'reject_action') {
      // Envoyer notification au passager
      courseRejeterParChauffeurNotification(
        rideId: payload['ride_id'],
        driverName: 'Votre nom',
        carDetails: 'Votre véhicule',
      );
    } else {}
  }

  /*
  *
  *============================
  * Les réponses du passager
  *============================
  */

  //  Notification d'Acceptation (Pour le Passager)
  static Future<void> coursePayerParClientNotification({
    required String driverName,
    required String carDetails,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'passenger_channel',
          'Statut des courses',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode,
      'Course Payé!',
      "Merci pour votre confiance!!! $driverName ($carDetails)",
      details,
      payload: jsonEncode({
        'type': 'ride_accepted',
        'ride_id': rideId,
        'driver_name': driverName,
      }),
    );
  }

  /*
  *
  *============================
  * Fin réponses du passager
  *============================
  */

   /*
  *
  *============================
  * Les réponses du chauffeur
  *============================
  */

  //  Notification d'Acceptation (Pour le Passager)
  static Future<void> showRideAcceptedNotification({
    required String driverName,
    required String carDetails,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'passenger_channel',
          'Statut des courses',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode,
      'Course acceptée!',
      '$driverName ($carDetails) vient de prendre votre course',
      details,
      payload: jsonEncode({
        'type': 'ride_accepted',
        'ride_id': rideId,
        'driver_name': driverName,
      }),
    );
  }

  //  Notification d'Acceptation (Pour le Passager)
  static Future<void> courseRejeterParChauffeurNotification({
    required String driverName,
    required String carDetails,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'passenger_channel',
          'Statut des courses',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode,
      'Course Rejetée!',
      '$driverName ($carDetails) vient de rejeter votre course',
      details,
      payload: jsonEncode({
        'type': 'ride_accepted',
        'ride_id': rideId,
        'driver_name': driverName,
      }),
    );
  }

  //  Notification d'Acceptation (Pour le Passager)
  static Future<void> courseEnCoursParChauffeurNotification({
    required String driverName,
    required String carDetails,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'passenger_channel',
          'Statut des courses',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode,
      'Course En cours!',
      'votre course course en encours vers la destination',
      details,
      payload: jsonEncode({
        'type': 'ride_accepted',
        'ride_id': rideId,
        'driver_name': driverName,
      }),
    );
  }

  //  Notification d'Acceptation (Pour le Passager)
  static Future<void> courseDemarerParChauffeurNotification({
    required String driverName,
    required String carDetails,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'passenger_channel',
          'Statut des courses',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode,
      'Course Démarer!',
      '$driverName ($carDetails) vient de démarer votre course',
      details,
      payload: jsonEncode({
        'type': 'ride_accepted',
        'ride_id': rideId,
        'driver_name': driverName,
      }),
    );
  }

  //  Notification d'Acceptation (Pour le Passager)
  static Future<void> courseFinieParChauffeurNotification({
    required String driverName,
    required String carDetails,
    required String rideId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'passenger_channel',
          'Statut des courses',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      rideId.hashCode,
      'Course Terminée!',
      "Félicitation course vient d'arriver à la destination!!! $driverName ($carDetails)",
      details,
      payload: jsonEncode({
        'type': 'ride_accepted',
        'ride_id': rideId,
        'driver_name': driverName,
      }),
    );
  }

  
}
