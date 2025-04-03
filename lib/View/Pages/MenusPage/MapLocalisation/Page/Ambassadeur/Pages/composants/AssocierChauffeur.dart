import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomDropdown.dart';
import 'package:lifti_app/Components/button.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/TaxiAssChauffeurModel.dart';
import 'package:lifti_app/Model/VehiculeModel.dart';

class AssocierVoitureChauffeur extends StatefulWidget {
  final VoitureModel vehicule;
  final Function(VoitureModel taxi) onClicFunction;
  const AssocierVoitureChauffeur({
    super.key,
    required this.vehicule,
    required this.onClicFunction,
  });

  @override
  State<AssocierVoitureChauffeur> createState() =>
      _AssocierVoitureChauffeurState();
}

class _AssocierVoitureChauffeurState extends State<AssocierVoitureChauffeur> {
  TextEditingController refChauffeur = TextEditingController();
  TextEditingController refVehicule = TextEditingController();
  TextEditingController refUser = TextEditingController();
  TextEditingController author = TextEditingController();
  int? selectedChauffeur;
  final formKey = GlobalKey<FormState>();

  late List<TaxiAssChauffeurModel> taxiList = [];
  bool isLoading = true;
  int idRole = 0;
  bool edit = false;

  Future<void> fetchUser() async {
    int? roleId = await CallApi.getUserRole();

    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    //passager
    List<dynamic> dataDash = await CallApi.fetchListData(
      'get_profile_taxi_vehicule/${widget.vehicule.id!.toString()}',
    );
    // print(dataDash);
    setState(() {
      idRole = roleId!;
      taxiList =
          dataDash.map((item) => TaxiAssChauffeurModel.fromMap(item)).toList();
      isLoading = false;
    });
  }
  /*
  *
  *=========================
  * Insertion de crud
  *=========================
  *
  */

  Future<void> storeConducteur() async {
    if (formKey.currentState!.validate()) {
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      String? sessionName = await CallApi.getNameConnected();
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (edit) {
        //modification
        fetchUser();
        for (var i = 0; i < taxiList.length; i++) {
          var item = taxiList[i];
          Map<String, dynamic> svData = {
            'id': item.id!.toString(),
            'refChauffeur': selectedChauffeur.toString(),
            'refVehicule': widget.vehicule.id!.toString(),
            'status': 1,
            'author': sessionName.toString(),
            'refUser': userId.toString(),
          };

          // print("svData: $svData");

          //modification des informations
          final response = await CallApi.insertData(
            endpoint: "mobile_store_conduicteur_taxi",
            data: svData,
          );

          final Map<String, dynamic> responseData = response;
          String message = responseData['data'] ?? "Message!!!";
          showSnackBar(context, message, 'success');
          widget.onClicFunction(widget.vehicule);
          Navigator.pop(context, true);
        }
      } else {
        //Insertion
        Map<String, dynamic> svData = {
          'id': "",
          'refChauffeur': selectedChauffeur.toString(),
          'refVehicule': widget.vehicule.id!.toString(),
          'status': 1,
          'author': sessionName.toString(),
          'refUser': userId.toString(),
        };

        final response = await CallApi.insertData(
          endpoint: "mobile_store_conduicteur_taxi",
          data: svData,
        );

        final Map<String, dynamic> responseData = response;
        String message = responseData['data'] ?? "Message!!!";
        showSnackBar(context, message, 'success');
        widget.onClicFunction(widget.vehicule);
        Navigator.pop(context, true);
      }
    }
  }

  //tester s'il existe ou pas
  showCountStoreExisting() async {
    final response = await CallApi.fetchListData(
      'get_count_store_conducteur_vehicule/${widget.vehicule.id!.toString()}',
    );
    int count = 0;
    List<dynamic> dataList = response;
    for (var i = 0; i < dataList.length; i++) {
      var item = dataList[i];
      count = item;

      if (count > 0) {
        setState(() {
          edit = true;
        });
      } else {
        setState(() {
          edit = false;
        });
      }
    }

    // print(count);
  }

  List<Map<String, dynamic>> chauffeurList = [];
  fetchDrivers() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    final response = await CallApi.fetchListData(
      'list_chauffeur_all_ambassadeur/${userId.toInt()}',
    );
    List<dynamic> data = response;
    setState(() {
      chauffeurList =
          data
              .map(
                (item) => {
                  "value": item["id"]!.toString(),
                  "text": item["name"],
                },
              )
              .toList();

      isLoading = false;
    });

    // print(chauffeurList);
  }

  @override
  void initState() {
    super.initState();
    showCountStoreExisting();
    fetchUser();
    fetchDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.40, // Augmenté à 75% pour plus de visibilité
      width: MediaQuery.of(context).size.width * 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Ce véhicule appartient-il à quel chauffeur?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            //boutton de recherche
            Padding(
              padding: EdgeInsets.all(0),
              child: Form(
                key: formKey,
                child: Center(
                  child: Column(
                    children: [
                      CustomDropdown(
                        validatorInput: true,
                        icon: Icons.local_taxi_sharp,
                        items: chauffeurList,
                        label: "Chauffeurs",
                        displayKey: "text",
                        valueKey: "value",
                        value: CallApi.getValidDropdownValue(
                          chauffeurList,
                          selectedChauffeur,
                          "value",
                        ),
                        onChanged: (value) {
                          if (value != null && value.toString().isNotEmpty) {
                            setState(() {
                              selectedChauffeur = int.parse(value.toString());
                            });

                            print('selectedChauffeur: $selectedChauffeur');
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Button(
                        label: edit ? "Modifier" : "Ajouter",
                        icon: edit ? Icons.edit : Icons.save,
                        press: () {
                          storeConducteur();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //formulaire ici
          ],
        ),
      ),
    );
  }
}
