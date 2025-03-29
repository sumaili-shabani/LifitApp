import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Controller/PusherService.dart';
import 'package:lifti_app/Model/DemandeTaxiModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class CommandeTaxiScreem extends StatefulWidget {
  const CommandeTaxiScreem({super.key});

  @override
  State<CommandeTaxiScreem> createState() => _CommandeTaxiScreemState();
}

class _CommandeTaxiScreemState extends State<CommandeTaxiScreem> {
  List<DemandeTaxiModel> orders = [];
  String searchQuery = '';
  bool loading = false;

  int refConnected = 0;
  getIdConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    int idUser = localStorage.getInt('idConnected')!;
    setState(() {
      refConnected = idUser;
    });

    // print('id connected: ${refConnected.toInt()}');

    //appelle de la fonction demande
    loadOrders(refConnected);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifie si la localisation est activée
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifie les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation ont été refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Les permissions de localisation sont définitivement refusées.',
      );
    }

    // Obtenir la position actuelle
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future getUserPosition() async {
    try {
      Position position = await _determinePosition();
      // print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      return position;
    } catch (e) {
      print("Erreur: $e");
    }
  }

  Future ChangeMyPosition() async {
    Position position = await getUserPosition();
    Map<String, dynamic> svData = {
      "id": refConnected.toInt(),
      "latUser": position.latitude,
      "lonUser": position.longitude,
    };

    await CallApi.postData("chauffeur_mobilechangePosition", svData);
  }

  Future reponseDemande(int id, int statut, int refPassager) async {
    try {
      setState(() {
        loading = true;
      });

      final response = await CallApi.fetchData(
        "checkEtat_chauffeur_mobile_demande_taxi/${id.toInt()}/${statut.toInt()}/${refPassager.toInt()}",
      );

      ChangeMyPosition();

      setState(() {
        loading = false;
      });

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "J'arrive!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction demande
      loadOrders(refConnected.toInt());
    } catch (e) {
      showSnackBar(context, e.toString(), 'danger');
    }
  }

  @override
  void initState() {
    super.initState();
    getIdConnected();
  }

  Future<void> loadOrders(int refChauffeur) async {
    setState(() {
      loading = true;
    });
    try {
      List<DemandeTaxiModel> fetchedOrders = await ApiService.fetchCommande(
        "chauffeur_mobile_demande_taxi/${refChauffeur.toInt()}",
      );
      setState(() {
        orders = fetchedOrders;
        loading = false;
      });
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  /// 🔹 **Méthode DELETE**
  Future<void> deleteData(int id) async {
    try {
      final response = await CallApi.deleteData(
        "chauffeur_mobile_delete_demande_taxi/${id.toInt()}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "Deleted!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction demande
      loadOrders(refConnected.toInt());
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  /*
  *
  *===============================
  * Pusher 
  *===============================
  *
  */

  /*
  *
  *===============================
  * Pusher 
  *===============================
  *
  */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text('Commandes de Taxi', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              getIdConnected();
            },
          ),
        ],
      ),

      body:
          loading == true
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // mes commandes
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChauffeurScreen(chauffeurId: 30),
                  ),
                  // fin commandes
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Rechercher une commande...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        if (!order.namePassager.toLowerCase().contains(
                          searchQuery,
                        )) {
                          return Container();
                        }
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: CallApi.getRandomColor(),
                              child: Text(
                                CallApi.limitText(order.namePassager, 1),
                              ),
                              // backgroundImage: NetworkImage(
                              //   "${CallApi.fileUrl}/images/${order.avatarPassager}",
                              // ),
                            ),
                            title: Text(order.namePassager),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                    SizedBox(width: 1),
                                    Text(
                                      '${CallApi.arrondirChiffre(order.lat)} ➝ ${CallApi.arrondirChiffre(order.lng)}',
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Date: ${CallApi.getFormatedDate(order.createdAt)}',
                                ),
                                Text(
                                  'Statut: ${order.statut == 0 ? "En attente" : "Terminée"}',
                                  style: TextStyle(
                                    color:
                                        order.statut == 0
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    setState(() {});

                                    try {
                                      reponseDemande(
                                        order.id,
                                        order.statut,
                                        order.refPassager,
                                      );
                                    } catch (e) {
                                      showSnackBar(
                                        context,
                                        e.toString(),
                                        'danger',
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    deleteData(order.id.toInt());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

class ChauffeurScreen extends StatefulWidget {
  final int chauffeurId;

  const ChauffeurScreen({required this.chauffeurId});

  @override
  _ChauffeurScreenState createState() => _ChauffeurScreenState();
}

class _ChauffeurScreenState extends State<ChauffeurScreen> {
  final PusherService pusherService = PusherService();
  Map<String, dynamic>? currentTaxiRequest;

  PusherChannelsFlutter pusher = PusherChannelsFlutter();
  Function(Map<String, dynamic>)?
  onNewTaxiRequest; // Callback pour mettre à jour l'UI

  Future<void> initPusher(int chauffeuiId) async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String bearerToken = localStorage.getString('token')!;
      print("Token: $bearerToken");
      await pusher.init(
        apiKey: CallApi.pusherAppKey,
        cluster: "mt1",
        useTLS: true,
        authEndpoint:
            "${CallApi.fileUrl}/broadcasting/auth?token=$bearerToken", // ✅ Ajout du token ici
        onEvent: (PusherEvent event) {
          print("📡 Nouvel événement : ${event.eventName}");
          print("📨 Données reçues : ${event.data}");

          if (event.eventName == "TaxiRequestEvent" ||
              event.eventName == "App\\Events\\TaxiRequestEvent") {
            print("🚖 Nouvelle demande de taxi détectée !");
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
          print("✅ Abonné avec succès au canal : $channelName");
        },
        onConnectionStateChange: (String previousState, String currentState) {
          print(
            "🔄 État de connexion Pusher : $previousState ➡️ $currentState",
          );
        },
        onError: (String message, int? code, dynamic e) {
          print("❌ Erreur Pusher : $message (Code: $code)");
        },
      );

      // ✅ Étape 1: Connexion à Pusher et attente de l'état CONNECTED
      await pusher.connect();
      print("🚀 Connexion à Pusher réussie");

      String channel =
          "chauffeur.$chauffeuiId"; // ✅ Vérifie bien que c'est un canal privé
      await pusher.subscribe(channelName: channel);
      print("📡 Abonnement au canal $channel réussi");

    } catch (e) {
      print("🚨 Erreur lors de l'initialisation de Pusher : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initPusher(30);
  }

  @override
  void dispose() {
    super.dispose();
    pusherService.pusher
        .disconnect(); // 🔹 Déconnecter Pusher pour éviter des mises à jour inutiles
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child:
              currentTaxiRequest == null
                  ? Text("🚖 En attente des commandes...")
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "📌 Nouvelle demande !",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Client : ${currentTaxiRequest!['nom']}"),
                      Text("Message : ${currentTaxiRequest!['message']}"),
                    ],
                  ),
        ),
      ],
    );
  }
}
