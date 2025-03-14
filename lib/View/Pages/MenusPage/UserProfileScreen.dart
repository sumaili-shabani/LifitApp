import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<List<UserModel>> futureUsers;
  List<ChauffeurDashBoardModel> dashInfo = [];

  UserModel? user;
  bool isLoading = true;
  int idRole = 0;

  Future<void> fetchUser() async {
    int? roleId = await CallApi.getUserRole();

    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    final response = await http.get(
      Uri.parse(
        '${CallApi.baseUrl.toString()}/user_mobile_info/${userId.toInt()}',
      ),
      headers: await CallApi.getHeaders(),
    );

    // print(response);
    if (roleId == 3) {
      //chauffeur
      List<dynamic> dataDash = await CallApi.fetchListData(
        'chauffeur_mobile_dashboard/${userId.toInt()}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        // print(data);
        setState(() {
          idRole = roleId!;
          user = UserModel.fromMap(data);
          dashInfo =
              dataDash
                  .map((item) => ChauffeurDashBoardModel.fromMap(item))
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erreur de chargement des données');
      }
    } else if (roleId == 4) {
      //passager
      List<dynamic> dataDash = await CallApi.fetchListData(
        'passager_mobile_dashboard/${userId.toInt()}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        // print(data);
        setState(() {
          idRole = roleId!;
          user = UserModel.fromMap(data);
          dashInfo =
              dataDash
                  .map((item) => ChauffeurDashBoardModel.fromMap(item))
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erreur de chargement des données');
      }
    } else if (roleId == 5) {
      //passager
      List<dynamic> dataDash = await CallApi.fetchListData(
        'passager_mobile_dashboard/${userId.toInt()}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        // print(data);
        setState(() {
          idRole = roleId!;
          user = UserModel.fromMap(data);
          dashInfo =
              dataDash
                  .map((item) => ChauffeurDashBoardModel.fromMap(item))
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erreur de chargement des données');
      }
    } else {}
  }

  /*
  *
  *=========================
  *upload des fichiers
  *=========================
  *
  */
  File? _imageFile;
  bool _isUploading = false;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sélectionnez d'abord une image")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String apiUrl =
          '${CallApi.baseUrl}/chauffeur_mobile_edit_photo_user'; // Change l'URL de ton API Laravel
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      if (userId == null) {
        throw Exception("ID utilisateur introuvable");
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll(await CallApi.getHeaders());

      request.files.add(
        await http.MultipartFile.fromPath("image", _imageFile!.path),
      );
      request.fields["data"] = jsonEncode({"id": userId});

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);

        setState(() {
          _imageUrl =
              decodedData['image_url'].toString(); // Convertir en String
          _imageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image mise à jour avec succès")),
        );
        //actualisation de la fonction user
        await fetchUser();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur d'upload")));
      }
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec de l'upload")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Fonction pour récupérer le token stocké localement

  /*
  *
  *=========================
  * Fin upload des fichiers
  *=========================
  *
  */

  @override
  void initState() {
    super.initState();

    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                // CircleAvatar(
                //   radius: 50,
                //   backgroundImage: NetworkImage(
                //     "${CallApi.fileUrl}/images/${user!.avatar}",
                //   ),
                // ),

                // uploader fichieer
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(File(_imageFile!.path)) as ImageProvider
                          : NetworkImage(
                            "${CallApi.fileUrl}/images/${user!.avatar}",
                          ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: _uploadImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 20,
                        child:
                            _isUploading
                                ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : Icon(Icons.upload, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // fin upload fichier
                SizedBox(height: 10),
                Text(
                  "${user!.name}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  idRole == 3
                      ? "Chauffeur Taxi - avec +2 ans d'expérience"
                      : idRole == 4
                      ? 'Passager Lifti'
                      : idRole == 5
                      ? 'Personne morale Lifti'
                      : 'Ambassadeur Lifti',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),

                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: Icon(Icons.car_crash, color: Colors.green),
                    title: Text("Moy. Distance mensuel en cours"),
                    trailing: Text(
                      "${dashInfo.isNotEmpty ? dashInfo.first.sumDistanceCourseEncours.toString() : 0} Km",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child:
                      idRole == 3
                          ? ListTile(
                            leading: Icon(
                              Icons.bar_chart,
                              color: Colors.green,
                            ),
                            title: Text("Total de Recharge mensuel"),
                            trailing: Text(
                              "${dashInfo.isNotEmpty ? dashInfo.first.sommeRecharge.toString() : 0} CDF",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                          : idRole == 4 || idRole == 5
                          ? ListTile(
                            leading: Icon(
                              Icons.bar_chart,
                              color: Colors.green,
                            ),
                            title: Text("Total de course Mensuel"),
                            trailing: Text(
                              "${dashInfo.isNotEmpty ? dashInfo.first.countCourse.toString() : 0} ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                          : SizedBox(),
                ),

                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: Icon(Icons.wallet, color: Colors.green),
                    title: Text("Paiement commission mensuel"),
                    trailing: Text(
                      "${dashInfo.isNotEmpty ? dashInfo.first.sommeRetrait.toString() : 0} CDF",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.phone, color: Colors.green),
                    title: Text("Téléphone"),
                    trailing: Text(
                      "${user!.telephone}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.email, color: Colors.red),
                    title: Text("Email"),
                    trailing: Text(
                      "${user!.email}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.male, color: Colors.blue),
                    title: Text("Sexe"),
                    trailing: Text(
                      "${user!.sexe}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.home, color: Colors.purple),
                    title: Text("Adresse Domicile"),
                    trailing: Text(
                      "${user!.adresse}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.payment, color: Colors.orange),
                    title: Text("Préférences de paiement"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${user!.designation},",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${user!.nomBanque}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
