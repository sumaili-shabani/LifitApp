import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/CustomDropdown.dart';
import 'package:lifti_app/Components/TextFildComponent.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/UserModel.dart';

class Addchauffeur extends StatefulWidget {
  final int? id;
  final String? avatar;
  final String? name;
  final String? email;
  final int? idRole;
  final String? roleName;
  final String? sexe;
  final String? telephone;
  final String? adresse;
  final int? active;
  final double? soldeCommission;
  final double? soldeRecette;
  final String? tel1;
  final String? tel2;
  final String? tel3;
  final String? tel4;
  final int? refBanque;
  final double? soldeBonus;
  final int? refMode;
  final String? numerocompte;
  final String? nomMode;
  final String? nomBanque;
  final String? designation;
  final String? createdAt;
  const Addchauffeur({
    super.key,
    this.id,
    this.avatar,
    this.name,
    this.email,
    this.idRole,
    this.roleName,
    this.sexe,
    this.telephone,
    this.adresse,
    this.active,
    this.soldeCommission,
    this.soldeRecette,
    this.tel1,
    this.tel2,
    this.tel3,
    this.tel4,
    this.refBanque,
    this.soldeBonus,
    this.refMode,
    this.numerocompte,
    this.nomMode,
    this.nomBanque,
    this.designation,
    this.createdAt,
  });

  @override
  State<Addchauffeur> createState() => _AddchauffeurState();
}

class _AddchauffeurState extends State<Addchauffeur> {
  UserModel? user;
  bool isLoading = true;
  bool edit = false;

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
      
    });

    // print(banqueList);
  }

  // changement de statut lors que je clique sur le boutton editer
 void chargerData() async {
    if (widget.id != null) {
      setState(() {
        edit = true;
        id.text = widget.id.toString();
        name.text = widget.name.toString();
        email.text = widget.email.toString();
        telephone.text = widget.telephone.toString();
        adresse.text = widget.adresse.toString();
        tel1.text = widget.tel1.toString();
        tel2.text = widget.tel2.toString();
        tel3.text = widget.tel3.toString();
        tel4.text = widget.tel4.toString();
        sexe.text = widget.sexe.toString();
        refMode.text = widget.refMode.toString();
        refBanque.text = widget.refBanque.toString();
        selectedSexe = widget.sexe.toString();
      });

      // Charger les modes de paiement
      await fetchModePaiement();

      // Vérifier si la valeur existe bien dans la liste avant de l'affecter
      if (modeList.any(
        (item) => item['id'].toString() == widget.refMode.toString(),
      )) {
        setState(() {
          selectedMode = widget.refMode.toString();
        });
      } else {
        print(
          "⚠️ refMode ${widget.refMode} ne correspond à aucun mode de paiement.",
        );
      }

      // Charger les banques en fonction du mode de paiement sélectionné
      await fetchBanquePaiement(int.parse(widget.refMode.toString()));

      // Vérifier si la valeur existe bien dans la liste avant de l'affecter
      if (banqueList.any(
        (item) => item['id'].toString() == widget.refBanque.toString(),
      )) {
        setState(() {
          selectedBanque = widget.refBanque.toString();
        });
      } else {
        print(
          "⚠️ refBanque ${widget.refBanque} ne correspond à aucune banque.",
        );
      }
    }
  }
  //insertion du chauffeur
  storeOrEditData() async {
    if (formKey.currentState!.validate()) {
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      if (edit) {
        try {
          Map<String, dynamic> svData = {
            "id": widget.id,
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
          // print(svData);
          final response = await CallApi.insertData(
            endpoint: "mobile_update_store_chauffeur",
            data: svData,
          );

          final Map<String, dynamic> responseData = response;
          String message = responseData['data'] ?? "Message!!!";
          showSnackBar(context, message, 'success');

          Navigator.pop(context, true);
          //appeler directement de la fonction de chargement des chauffeur
        } catch (e) {
          showSnackBar(context, e.toString(), 'success');
          print(e.toString());
        }
      } else {
        try {
          Map<String, dynamic> svData = {
            "id": "",
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

          // print(svData);
          final response = await CallApi.insertData(
            endpoint: "mobile_update_store_chauffeur",
            data: svData,
          );
          final Map<String, dynamic> responseData = response;
          String message = responseData['data'] ?? "Message!!!";
          showSnackBar(context, message, 'success');

          Navigator.pop(context, true);
          //appeler directement de la fonction de chargement des chauffeur
        } catch (e) {
          showSnackBar(context, e.toString(), 'success');
          print(e.toString());
        }
      }
    } else {
      return null;
    }
  }

  
  @override
  void initState() {
    super.initState();
    fetchModePaiement();
    chargerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text(
          edit ? 'Editer le chauffeur' : 'Ajout de chauffeur',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              storeOrEditData();
            },
            icon: Icon(edit ? Icons.edit : Icons.save, color: Colors.white),
            tooltip: edit ? "Modifier" : "Enregistrer",
          ),
        ],
      ),
      body:
          isLoading
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
                          SizedBox(height: 10),
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
                            keyboardTypeNumber: true,
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
                            keyboardTypeNumber: true,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "N° de Tél Airtel",
                            hint: "Entrer votre N° de Tél Airtel",
                            icon: Icons.phone,
                            controller: tel2,
                            validatorInput: false,
                            keyboardTypeNumber: true,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "N° de Tél Orange",
                            hint: "Entrer votre N° de Tél Orange",
                            icon: Icons.phone,
                            controller: tel3,
                            validatorInput: false,
                            keyboardTypeNumber: true,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "N° de Tél Africel",
                            hint: "Entrer votre N° de Tél Africel",
                            icon: Icons.phone,
                            controller: tel4,
                            validatorInput: false,
                            keyboardTypeNumber: true,
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
                                // print("selectedMode: $selectedMode");
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
