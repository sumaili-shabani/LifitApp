import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomDropdown.dart';
import 'package:lifti_app/Components/TextFildComponent.dart';
import 'package:lifti_app/Components/button.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/UserModel.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late Future<List<UserModel>> futureUsers;

  UserModel? user;
  bool isLoading = true;

  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController telephone = TextEditingController();
  TextEditingController adresse = TextEditingController();
  TextEditingController sexe = TextEditingController();
  TextEditingController tel1 = TextEditingController();
  TextEditingController tel2 = TextEditingController();
  TextEditingController tel3 = TextEditingController();
  TextEditingController tel4 = TextEditingController();
  TextEditingController refrefBanque = TextEditingController();
  TextEditingController refMode = TextEditingController();
  TextEditingController refBanque = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // Exemple de données JSON
  List<Map<String, dynamic>> sexeList = [
    {"value": "M", "text": "M"},
    {"value": "F", "text": "F"},
  ];
  List<Map<String, dynamic>> modeList = [
    {"value": "1", "text": "Banque"},
  ];
  List<Map<String, dynamic>> banqueList = [
    {"value": "1", "text": "TMB"},
  ];
  String? selectedSexe;
  String? selectedMode;
  String? selectedBanque;

  Future<void> fetchUser() async {
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

    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      // print(data);

      name.text = data!['name'];
      email.text = data!['email'];
      telephone.text = data!['telephone'];

      tel1.text = data!['tel1'];
      tel2.text = data!['tel2'];
      tel3.text = data!['tel3'];
      tel4.text = data!['tel4'];
      sexe.text = data!['sexe'];
      refMode.text = data!['refMode'];
      refBanque.text = data!['refBanque'];

      setState(() {
        user = UserModel.fromMap(data);
        selectedSexe = data!['sexe'];
        isLoading = false;
      });

      adresse.text = data!['adresse'];

      // setState(() {
      //   selectedSexe = data['sexe'].toString();
      //   selectedMode = data['refMode'].toString();
      // });

      print("sexe: ${selectedSexe.toString()}");
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchModePaiement();
  }

  editData() async {
    if (formKey.currentState!.validate()) {
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      try {
        Map<String, dynamic> svData = {
          "id": userId,
          "name": name.text,
          "email": email.text,
          "adresse": adresse.text,
          "telephone": telephone.text,
          "sexe": selectedSexe.toString(),
          "tel1": tel1.text,
          "tel2": tel2.text,
          "tel3": tel3.text,
          "tel4": tel4.text,
          "refMode": int.parse(selectedMode.toString()),
          "refBanque": int.parse(selectedBanque.toString()),
        };

        print(svData);
        final response = await CallApi.postData(
          "mobile_update_store_chauffeur",
          svData,
        );
        final Map<String, dynamic> responseData = response;
        String message = responseData['data'] ?? "Message!!!";
        showSnackBar(context, message, 'success');

        fetchUser();
      } catch (e) {
        showSnackBar(context, e.toString(), 'success');
        print(e.toString());
      }
    } else {}
  }

  fetchModePaiement() async {
    final response = await CallApi.fetchListData('modible_fetch_modepaie');
    List<dynamic> data = response;

    setState(() {
      modeList =
          data
              .map(
                (item) => {
                  "value": item["value"]!.toString(),
                  "text": item["text"],
                },
              )
              .toList();
      ;
      isLoading = false;
    });

    // print(modeList);
  }

  fetchBanquePaiement(int refMode) async {
    final response = await CallApi.fetchListData(
      'modible_fetch_banque_by_mode/${refMode.toString()}',
    );
    List<dynamic> data = response;

    setState(() {
      banqueList =
          data
              .map(
                (item) => {
                  "value": item["value"]!.toString(),
                  "text": item["text"],
                },
              )
              .toList();
      ;
    });

    // print(banqueList);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Form(
              key: formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    TextFildComponent(
                      labeltext: "Nom",
                      hint: "Entrer votre nom",
                      icon: Icons.person,
                      controller: name,
                      validatorInput: true,
                    ),
                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "Email et N° Téléphone",
                      hint: "Entrer Email  ou N° Téléphone",
                      icon: Icons.email,
                      controller: email,
                      validatorInput: true,
                    ),
                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "N° de Téléphone Principal",
                      hint: "Entrer votre N° de Téléphone",
                      icon: Icons.phone,
                      controller: telephone,
                      validatorInput: true,
                    ),
                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "Adresse domicile",
                      hint: "Entrer votre Adresse",
                      icon: Icons.location_city,
                      controller: adresse,
                      validatorInput: true,
                    ),

                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "N° de Tél Vodacom",
                      hint: "Entrer votre N° de Tél Vodacom",
                      icon: Icons.phone,
                      controller: tel1,
                      validatorInput: false,
                    ),
                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "N° de Tél Airtel",
                      hint: "Entrer votre N° de Tél Airtel",
                      icon: Icons.phone,
                      controller: tel2,
                      validatorInput: false,
                    ),
                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "N° de Tél Orange",
                      hint: "Entrer votre N° de Tél Orange",
                      icon: Icons.phone,
                      controller: tel3,
                      validatorInput: false,
                    ),
                    SizedBox(height: 10),
                    TextFildComponent(
                      labeltext: "N° de Tél Africel",
                      hint: "Entrer votre N° de Tél Africel",
                      icon: Icons.phone,
                      controller: tel4,
                      validatorInput: false,
                    ),
                    SizedBox(height: 10),

                    CustomDropdown(
                      validatorInput: true,
                      icon: Icons.female,
                      items: sexeList,
                      label: "Sélectionnez le sexe",
                      displayKey: "text",
                      valueKey: "value",
                      value: selectedSexe,
                      onChanged: (value) {
                        if (value != "") {
                          setState(() {
                            selectedSexe = value.toString();
                            // sexe = value as TextEditingController;
                          });
                        } else {}
                      },
                    ),
                    SizedBox(height: 10),

                    CustomDropdown(
                      validatorInput: true,
                      icon: Icons.mobile_friendly,
                      items: modeList,
                      label: "Préférence mode de paiement",
                      displayKey: "text",
                      valueKey: "value",
                      value: selectedMode,

                      onChanged: (value) {
                        if (value != "") {
                          setState(() {
                            selectedMode = value.toString();
                            // refMode = value as TextEditingController;
                          });
                          fetchBanquePaiement(
                            int.parse(selectedMode.toString()),
                          );
                        } else {}
                      },
                    ),
                    SizedBox(height: 10),
                    CustomDropdown(
                      validatorInput: true,
                      icon: Icons.install_mobile_rounded,
                      items: banqueList,
                      label: "Préférence de paiement",
                      displayKey: "text",
                      valueKey: "value",
                      value: selectedBanque,
                      onChanged: (value) {
                        if (value != "") {
                          setState(() {
                            selectedBanque = value.toString();
                            // refBanque = value as TextEditingController;
                          });
                        } else {}
                      },
                    ),
                    SizedBox(height: 20),
                    Button(
                      icon: Icons.edit,
                      label: "Editer",
                      press: () {
                        if (selectedBanque != "") {
                          // print("idBanque: ${selectedSexe.toString()}");
                          editData();
                        } else {
                          showSnackBar(
                            context,
                            "Vellez selection tous les champs",
                            'danger',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
