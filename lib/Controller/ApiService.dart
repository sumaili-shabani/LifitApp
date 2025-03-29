import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/BarData.dart';
import 'package:lifti_app/Model/ChartData.dart';
import 'package:lifti_app/Model/DemandeTaxiModel.dart';
import 'package:lifti_app/Model/PieData.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';


class ApiService {
  PusherChannelsFlutter pusher = PusherChannelsFlutter();

  static Future<List<PieData>> fetchPieData(String url) async {
    String? token = await CallApi.getToken();
    final response = await http.get(
      Uri.parse(
        "${CallApi.baseUrl.toString()}/${url.toString()}",
      ),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => PieData.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<BarData>> fetchBarData(String url) async {
    String? token = await CallApi.getToken();
    final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => BarData.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<ChartData>> fetchColumnData(String url) async {
    String? token = await CallApi.getToken();
    final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => ChartData.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  //affichage des commandes

  static Future<List<DemandeTaxiModel>> fetchCommande(String url) async {
    String? token = await CallApi.getToken();
    final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((item) => DemandeTaxiModel.fromMap(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  static Future<List<dynamic>> getDataApi(String url) async{
    String? token = await CallApi.getToken();
   final response = await http.get(
      Uri.parse("${CallApi.baseUrl.toString()}/${url.toString()}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> data = jsonData;
      // Map<String, dynamic> data = jsonData['data'];
      return data;
    } else {
      throw Exception("Erreur lors de la récupération des données");
    }
  }

  Future<void> initPusher() async {
    try {
      await pusher.init(
        apiKey: CallApi.pusherAppKey,
        cluster: "mt1",
        useTLS: true, // 🔥 Ajout de TLS pour éviter des erreurs WebSocket
        authEndpoint: "${CallApi.fileUrl}/broadcasting/auth", // Auth Laravel
        onEvent: (PusherEvent event) {
          print("📡 Nouvel événement : ${event.eventName}");
          print("📨 Données reçues : ${event.data}");
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          print("✅ Abonné avec succès au canal : $channelName");
        },
        onConnectionStateChange: (String previousState, String currentState) {
          print("🔄 État de connexion Pusher : $previousState ➡️ $currentState");
        },
        onError: (String message, int? code, dynamic e) {
          print("❌ Erreur Pusher : $message (Code: $code)");
        },
      );

      await pusher.subscribe(channelName: "chauffeur.30"); // Remplace par ton canal privé
      print("📡 Abonnement au canal privé-chauffeur-30 réussi");

      await pusher.connect();
      print("🚀 Connexion à Pusher réussie");
    } catch (e) {
      print("🚨 Erreur lors de l'initialisation de Pusher : $e");
    }
  }


  static Future<String> getPlaceName(double latitude, double longitude) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude",
    );

    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "Flutter-App"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["display_name"] ?? "Lieu inconnu";
        // return data["name"] ?? "Lieu inconnu";
      } else {
        return "Erreur de récupération";
      }
    } catch (e) {
      return "Erreur : $e";
    }
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si la localisation est activée
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Service de localisation désactivé.");
      return null;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permission refusée.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permission refusée définitivement.");
      return null;
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }


  

  





 
  






}
