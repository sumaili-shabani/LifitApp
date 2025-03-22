import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PusherService {
  PusherChannelsFlutter pusher = PusherChannelsFlutter();
  Function(Map<String, dynamic>)?
  onNewTaxiRequest; // Callback pour mettre à jour l'UI

 Future<void> initPusher(int chauffeurId) async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String bearerToken = localStorage.getString('token')!;

      print("token: $bearerToken");
      await pusher.init(
        apiKey: CallApi.pusherAppKey,
        cluster: "mt1",
        useTLS: true, // 🔥 Ajout de TLS pour éviter des erreurs WebSocket
        authEndpoint: "${CallApi.siteUrl}/broadcasting/auth",
        onEvent: (PusherEvent event) {
          print("📡 Événement reçu : ${event.eventName}");

          if (event.eventName == "App\\Events\\TaxiRequestEvent") {
            print("🚖 Nouvelle demande de taxi détectée !");
            print("🔽 Données reçues : ${event.data}");

            if (onNewTaxiRequest != null) {
              try {
                Map<String, dynamic> data = jsonDecode(event.data);
                onNewTaxiRequest!(data);
              } catch (e) {
                print("⚠️ Erreur de conversion des données : $e");
              }
            }
          }
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          print("✅ Abonnement réussi : $channelName");
        },
        onConnectionStateChange: (String previousState, String currentState) {
          print(
            "🔄 Changement d'état Pusher : $previousState ➡️ $currentState",
          );
        },
        onError: (String message, int? code, dynamic e) {
          print("❌ Erreur Pusher : $message (Code: $code)");
        },
      );

      // ✅ Étape 1: Connexion à Pusher et attente de l'état CONNECTED
      await pusher.connect();

      // Attendre que Pusher soit bien connecté
      await Future.delayed(
        Duration(seconds: 2),
      ); // 🔥 Donne du temps à Pusher pour se connecter

      // ✅ Étape 2: Récupérer le socket_id après connexion
      String? socketId;
      int attempts = 0;
      while (socketId == null || socketId.isEmpty) {
        socketId = await pusher.getSocketId();
        print("🔌 Tentative de récupération du socket_id : $socketId");
        if (attempts++ >= 3)
          break; // 🔥 Évite une boucle infinie si Pusher ne répond pas
        await Future.delayed(Duration(seconds: 1)); // 🔥 Attente supplémentaire
      }

      if (socketId == null || socketId.isEmpty) {
        throw Exception("❌ Impossible de récupérer le socket_id !");
      }

      print("🔌 Socket ID final récupéré : $socketId");

      // ✅ Étape 3: Authentification Laravel Sanctum avec le socket_id
      String channel = "chauffeur.$chauffeurId";
      var response = await http.post(
        Uri.parse("${CallApi.siteUrl}/broadcasting/auth"),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "channel_name": channel,
          "socket_id": socketId, // ✅ Vrai socket_id ici
        }),
      );

      if (response.statusCode == 200) {
        print("🔑 Auth Laravel Sanctum OK !");
      } else {
        throw Exception("⚠️ Auth Laravel Sanctum échouée !");
      }

      // ✅ Étape 4: Abonnement au canal
      await pusher.subscribe(channelName: channel);
      print("🚖 Connecté à Pusher sur le canal : $channel");
    } catch (e) {
      print("🚨 Erreur Pusher : $e");
    }
  }
}
