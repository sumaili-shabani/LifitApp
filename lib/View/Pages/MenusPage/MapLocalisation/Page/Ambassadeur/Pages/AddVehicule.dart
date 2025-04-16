import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/CustomDropdown.dart';
import 'package:lifti_app/Components/TextFildComponent.dart';
import 'package:lifti_app/Components/button.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/UserModel.dart';

class AddVehicule extends StatefulWidget {
  final int? id;
  final String? genreVehicule;
  final String? numPlaqueVehicule;
  final String? numChassiVehicule;
  final String? nomCouleur;
  final String? numMoteurVehicule;
  final String? dateFabrication;
  final int? refCouleur;
  final int? refCategorie;
  final String? numImpotVehicule;
  final String? nomProprietaire;
  final String? adresseProprietaire;
  final String? contactProprietaire;
  final int? refOrganisation;
  final dynamic numroIdentification;
  final String? author;
  final int? refUser;
  final String? nomCategorieVehicule;
  final int? refMarque;
  final String? nomMarque;
  final String? createdAt;
  final int? capo;
  final int? nbrPlace;
  final dynamic codeAmbassadeur;
  final String? imageVehicule;
  final dynamic fileVehicule;
  final int? refTypeCourse;
  final String? detailCapo;
  final String? typeCarburant;
  final String? nomTypeCourse;
  final String? location;
  final String? imageTypeCourse;
  final String? nomOrganisation;
  final String? adresseOrganisation;
  final String? detailsOrganisation;
  final int? refTypeOrg;
  final String? nomTypeOrganisation;
  const AddVehicule({
    super.key,
    this.id,
    this.genreVehicule,
    this.numPlaqueVehicule,
    this.numChassiVehicule,
    this.nomCouleur,
    this.numMoteurVehicule,
    this.dateFabrication,
    this.refCouleur,
    this.refCategorie,
    this.numImpotVehicule,
    this.nomProprietaire,
    this.adresseProprietaire,
    this.contactProprietaire,
    this.refOrganisation,
    this.numroIdentification,
    this.author,
    this.refUser,
    this.nomCategorieVehicule,
    this.refMarque,
    this.nomMarque,
    this.createdAt,
    this.capo,
    this.nbrPlace,
    this.codeAmbassadeur,
    this.imageVehicule,
    this.fileVehicule,
    this.refTypeCourse,
    this.detailCapo,
    this.typeCarburant,
    this.nomTypeCourse,
    this.location,
    this.imageTypeCourse,
    this.nomOrganisation,
    this.adresseOrganisation,
    this.detailsOrganisation,
    this.refTypeOrg,
    this.nomTypeOrganisation,
  });

  @override
  State<AddVehicule> createState() => _AddVehiculeState();
}

class _AddVehiculeState extends State<AddVehicule> {
  UserModel? user;
  bool isLoading = true;
  bool edit = false;

  TextEditingController id = TextEditingController();
  TextEditingController genreVehicule = TextEditingController();
  TextEditingController numPlaqueVehicule = TextEditingController();
  TextEditingController numChassiVehicule = TextEditingController();
  TextEditingController numMoteurVehicule = TextEditingController();
  TextEditingController dateFabrication = TextEditingController();
  TextEditingController refCouleur = TextEditingController();
  TextEditingController refCategorie = TextEditingController();
  TextEditingController numImpotVehicule = TextEditingController();
  TextEditingController nomProprietaire = TextEditingController();
  TextEditingController adresseProprietaire = TextEditingController();
  TextEditingController contactProprietaire = TextEditingController();
  TextEditingController author = TextEditingController();
  TextEditingController refUser = TextEditingController();
  TextEditingController refTypeOrg = TextEditingController();
  TextEditingController refOrganisation = TextEditingController();
  TextEditingController nbrPlace = TextEditingController();
  TextEditingController capo = TextEditingController();
  TextEditingController codeAmbassadeur = TextEditingController();
  TextEditingController imageVehicule = TextEditingController();
  TextEditingController fileVehicule = TextEditingController();
  TextEditingController refTypeCourse = TextEditingController();
  TextEditingController detailCapo = TextEditingController();
  TextEditingController typeCarburant = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // Exemple de données JSON
  List<Map<String, dynamic>> marqueList = [];
  List<Map<String, dynamic>> categoryVehiculeList = [];
  List<Map<String, dynamic>> typeCourseList = [];
  List<Map<String, dynamic>> couleurList = [];
  List<Map<String, dynamic>> organisationList = [];
  List<Map<String, dynamic>> typeorganisationList = [];

  // Exemple de données JSON
  List<Map<String, dynamic>> capoList = [
    {"value": 1, "text": "Oui"},
    {"value": 0, "text": "Non"},
  ];
  // Carburant
  List<Map<String, dynamic>> tailleCoffreList = [
    {"value": "Patit", "text": "Patit"},
    {"value": "Moyen", "text": "Moyen"},
    {"value": "Grand", "text": "Grand"},
  ];
  // Essence
  List<Map<String, dynamic>> typeCarburantList = [
    {"value": "Essence", "text": "Essence"},
    {"value": "Gazuel", "text": "Gazuel"},
    {"value": "Autre", "text": "Autre"},
  ];

  int? selectedMarque;
  int? selectedCategoryVehicule;
  int? selectedTypeCourse;
  int? selectedCouleur;
  int? selectedOrganisation;
  int? selectedTypeOrganisation;

  int? selectedCapo;
  String? selectedTailleCoffre;
  String? selectedTypeCarburant;

  fetchMarque() async {
    final response = await CallApi.fetchListData('fetch_marque_2');
    List<dynamic> data = response;
    setState(() {
      marqueList =
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

    // print(marqueList);
  }

  fetchCouleur() async {
    final response = await CallApi.fetchListData('fetch_couleur_2');
    List<dynamic> data = response;
    setState(() {
      couleurList =
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

    // print(couleurList);
  }

  fetchTypeOrganisation() async {
    final response = await CallApi.fetchListData('fetch_ttype_organisation_2');
    List<dynamic> data = response;
    setState(() {
      typeorganisationList =
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

    // print(typeorganisationList);
  }

  fetchTypeCourse() async {
    final response = await CallApi.fetchListData('fetch_typecourse_2');
    List<dynamic> data = response;
    setState(() {
      typeCourseList =
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

    // print(typeCourseList);
  }

  fetchCategoryVehicule(int refCle) async {
    final response = await CallApi.fetchListData(
      'fetch_categorie_vehicule_tug_by_marque/${refCle.toString()}',
    );
    List<dynamic> data = response;
    setState(() {
      categoryVehiculeList =
          data
              .map(
                (item) => {
                  "value": item["value"]!.toString(),
                  "text": item["text"],
                },
              )
              .toList();
    });

    // print(categoryVehiculeList);
  }

  fetchOrganisation(int refCle) async {
    final response = await CallApi.fetchListData(
      'fetch_organisation_tug_by_typeOrg/${refCle.toString()}',
    );
    List<dynamic> data = response;
    setState(() {
      organisationList =
          data
              .map(
                (item) => {
                  "value": item["value"]!.toString(),
                  "text": item["text"],
                },
              )
              .toList();
    });

    // print(organisationList);
  }

  fetchcodeAmbassadeur(String codeAmbassadeur) async {
    final response = await CallApi.fetchListData(
      'showUserBycodeAmbassadeur/${codeAmbassadeur.toString()}',
    );
    List<dynamic> data = response;
    for (var i = 0; i < data.length; i++) {
      var item = data[i];

      setState(() {
        refUser.text = item['id'].toString();
      });
    }

    // print(data);
  }

  // changement de statut lors que je clique sur le boutton editer
  void chargerData() async {
    fetchMarque();
    fetchCouleur();
    fetchTypeCourse();
    fetchTypeOrganisation();
    if (widget.id != null) {
      setState(() {
        edit = true;
        id.text = widget.id.toString();
        genreVehicule.text = widget.genreVehicule.toString();
        numPlaqueVehicule.text = widget.numPlaqueVehicule.toString();
        numChassiVehicule.text = widget.numChassiVehicule.toString();
        numMoteurVehicule.text = widget.numMoteurVehicule.toString();
        dateFabrication.text = widget.dateFabrication.toString();
        refCouleur.text = widget.refCouleur.toString();
        refCategorie.text = widget.refCategorie.toString();
        numImpotVehicule.text = widget.numImpotVehicule.toString();
        nomProprietaire.text = widget.nomProprietaire.toString();
        adresseProprietaire.text = widget.adresseProprietaire.toString();
        contactProprietaire.text = widget.contactProprietaire.toString();
        author.text = widget.author.toString();
        refUser.text = widget.refUser.toString();
        refTypeOrg.text = widget.refTypeOrg.toString();
        refOrganisation.text = widget.refOrganisation.toString();
        nbrPlace.text = widget.nbrPlace.toString();
        capo.text = widget.capo.toString();
        codeAmbassadeur.text = widget.codeAmbassadeur.toString();
        imageVehicule.text = widget.imageVehicule.toString();
        fileVehicule.text = widget.fileVehicule.toString();
        refTypeCourse.text = widget.refTypeCourse.toString();
        detailCapo.text = widget.detailCapo.toString();
        typeCarburant.text = widget.typeCarburant.toString();
        //initialisation de custoBoxe
        selectedCapo =
            widget.capo != null ? int.parse(widget.capo.toString()) : 0;
        selectedTailleCoffre =
            widget.capo != null ? widget.detailCapo.toString() : "";
        selectedTypeCarburant =
            widget.typeCarburant != null ? widget.typeCarburant.toString() : "";
        selectedMarque =
            widget.refMarque != null
                ? int.parse(widget.refMarque.toString())
                : 0;

        selectedCategoryVehicule =
            widget.refCategorie != null
                ? int.parse(widget.refCategorie.toString())
                : 0;
        selectedTypeOrganisation =
            widget.refTypeOrg != null
                ? int.parse(widget.refTypeOrg.toString())
                : 0;
        selectedOrganisation =
            widget.refOrganisation != null
                ? int.parse(widget.refOrganisation.toString())
                : 0;
        selectedTypeCourse =
            widget.refTypeCourse != null
                ? int.parse(widget.refTypeCourse.toString())
                : 0;
      });
    }
  }

  //insertion du chauffeur
  storeOrEditData() async {
    if (formKey.currentState!.validate()) {
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      String? sessionName = await CallApi.getNameConnected();
      if (edit) {
        setState(() {
          refCategorie.text = selectedCategoryVehicule.toString();
          refCouleur.text = selectedCouleur.toString();
          refOrganisation.text = selectedOrganisation.toString();
          refTypeCourse.text = selectedTypeCourse.toString();
          refTypeOrg.text = selectedTypeOrganisation.toString();
          capo.text = selectedCapo.toString();
          detailCapo.text = selectedTailleCoffre.toString();
          typeCarburant.text = selectedTypeCarburant.toString();
          author.text = sessionName.toString();
        });

        try {
          Map<String, dynamic> svData = {
            "id": widget.id.toString(),
            "genreVehicule": genreVehicule.text.toString(),
            "numPlaqueVehicule": numPlaqueVehicule.text.toString(),
            "numChassiVehicule": numChassiVehicule.text.toString(),
            "numMoteurVehicule": numMoteurVehicule.text.toString(),
            "dateFabrication": dateFabrication.text.toString(),
            "refCouleur": refCouleur.text.toString(),
            "refCategorie": refCategorie.text.toString(),
            "numImpotVehicule": numImpotVehicule.text.toString(),
            "nomProprietaire": nomProprietaire.text.toString(),
            "adresseProprietaire": adresseProprietaire.text.toString(),
            "contactProprietaire": contactProprietaire.text.toString(),
            "author": author.text.toString(),
            "refUser": refUser.text.toString(),
            "refTypeOrg": refTypeOrg.text.toString(),
            "refOrganisation": refOrganisation.text.toString(),
            "nbrPlace": nbrPlace.text.toString(),
            "capo": capo.text.toString(),
            "codeAmbassadeur": codeAmbassadeur.text.toString(),
            "imageVehicule": imageVehicule.text.toString(),
            "fileVehicule": fileVehicule.text.toString(),
            "refTypeCourse": refTypeCourse.text.toString(),
            "detailCapo": detailCapo.text.toString(),
            "typeCarburant": typeCarburant.text.toString(),
          };
          // print(svData);
          final response = await CallApi.insertData(
            endpoint: "insert_vehicule",
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
        if (refUser.text != '') {
          setState(() {
            refCategorie.text = selectedCategoryVehicule.toString();
            refCouleur.text = selectedCouleur.toString();
            refOrganisation.text = selectedOrganisation.toString();
            refTypeCourse.text = selectedTypeCourse.toString();
            refTypeOrg.text = selectedTypeOrganisation.toString();
            capo.text = selectedCapo.toString();
            detailCapo.text = selectedTailleCoffre.toString();
            typeCarburant.text = selectedTypeCarburant.toString();
            author.text = sessionName.toString();
          });

          try {
            Map<String, dynamic> svData = {
              "id": "",
              "genreVehicule": genreVehicule.text.toString(),
              "numPlaqueVehicule": numPlaqueVehicule.text.toString(),
              "numChassiVehicule": numChassiVehicule.text.toString(),
              "numMoteurVehicule": numMoteurVehicule.text.toString(),
              "dateFabrication": dateFabrication.text.toString(),
              "refCouleur": refCouleur.text.toString(),
              "refCategorie": refCategorie.text.toString(),
              "numImpotVehicule": numImpotVehicule.text.toString(),
              "nomProprietaire": nomProprietaire.text.toString(),
              "adresseProprietaire": adresseProprietaire.text.toString(),
              "contactProprietaire": contactProprietaire.text.toString(),
              "author": author.text.toString(),
              "refUser": refUser.text.toString(),
              "refTypeOrg": refTypeOrg.text.toString(),
              "refOrganisation": refOrganisation.text.toString(),
              "nbrPlace": nbrPlace.text.toString(),
              "capo": capo.text.toString(),
              "codeAmbassadeur": codeAmbassadeur.text.toString(),
              "imageVehicule": imageVehicule.text.toString(),
              "fileVehicule": fileVehicule.text.toString(),
              "refTypeCourse": refTypeCourse.text.toString(),
              "detailCapo": detailCapo.text.toString(),
              "typeCarburant": typeCarburant.text.toString(),
            };

            // print(svData);
            final response = await CallApi.insertData(
              endpoint: "insert_vehicule",
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
          showSnackBar(
            context,
            "Veillez entrer le vrai code de l'ambassadeur",
            'danger',
          );
        }
      }
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMarque();
    fetchCouleur();
    fetchTypeCourse();
    fetchTypeOrganisation();

    chargerData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text(
          edit ? 'Editer le véhicule' : 'Ajout de véhicule',
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
                            labeltext: "Genre du véhicule",
                            hint: "Entrer le Genre",
                            icon: Icons.car_crash,
                            controller: genreVehicule,
                            validatorInput: true,
                          ),
                          SizedBox(height: 10),

                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.local_taxi_sharp,
                            items: marqueList,
                            label: "Marque",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              marqueList,
                              selectedMarque,
                              "value",
                            ),
                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedMarque = int.parse(value.toString());
                                });

                                print('selectedMarque: $selectedMarque');

                                fetchCategoryVehicule(selectedMarque!);
                              }
                            },
                          ),
                          SizedBox(height: 10),

                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.mobile_friendly,
                            items: categoryVehiculeList,
                            label: "Type de véhicule",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              categoryVehiculeList,
                              selectedCategoryVehicule,
                              "value",
                            ),

                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedCategoryVehicule = int.parse(
                                    value.toString(),
                                  );
                                });
                              } else {}
                            },
                          ),
                          SizedBox(height: 10),
                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.install_mobile_rounded,
                            items: couleurList,
                            label: "Couleur",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              couleurList,
                              selectedCouleur,
                              "value",
                            ),

                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedCouleur = int.parse(value.toString());
                                  // refBanque = value as TextEditingController;
                                });
                              } else {}
                            },
                          ),

                          SizedBox(height: 10),

                          TextFildComponent(
                            labeltext: "Nombre de siege",
                            hint: "Entrer le nombre de place",
                            icon: Icons.info_outline,
                            controller: nbrPlace,
                            validatorInput: true,
                          ),
                          SizedBox(height: 10),

                          TextFildComponent(
                            labeltext: "N° de plaque",
                            hint: "Entrer le N° de plaque",
                            icon: Icons.info_outline,
                            controller: numPlaqueVehicule,
                            validatorInput: true,
                          ),
                          SizedBox(height: 10),

                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.storefront,
                            items: capoList,
                            label: "contient-il un coffre?",
                            displayKey: "text",
                            valueKey: "value",
                            value: selectedCapo,
                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedCapo = int.parse(value.toString());
                                });
                              } else {}
                            },
                          ),
                          SizedBox(height: 10),
                          selectedCapo != null && (selectedCapo == 1)
                              ? Column(
                                children: [
                                  CustomDropdown(
                                    validatorInput: true,
                                    icon: Icons.density_medium,
                                    items: tailleCoffreList,
                                    label: "Taille de coffre",
                                    displayKey: "text",
                                    valueKey: "value",
                                    value: CallApi.getValidDropdownValue(
                                      tailleCoffreList,
                                      selectedTailleCoffre,
                                      "value",
                                    ),

                                    onChanged: (value) {
                                      if (value != "") {
                                        setState(() {
                                          selectedTailleCoffre =
                                              value.toString();
                                        });
                                      } else {}
                                    },
                                  ),
                                  SizedBox(height: 10),
                                ],
                              )
                              : SizedBox(),

                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.cases_rounded,
                            items: typeCarburantList,
                            label: "type de carburant",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              typeCarburantList,
                              selectedTypeCarburant,
                              "value",
                            ),
                            onChanged: (value) {
                              if (value != "") {
                                setState(() {
                                  selectedTypeCarburant = value.toString();
                                });
                              } else {}
                            },
                          ),
                          SizedBox(height: 10),

                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.category,
                            items: typeCourseList,
                            label: "Type de course",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              typeCourseList,
                              selectedTypeCourse,
                              "value",
                            ),
                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedTypeCourse = int.parse(
                                    value.toString(),
                                  );
                                });
                              } else {}
                            },
                          ),
                          SizedBox(height: 10),

                          TextFildComponent(
                            labeltext: "N° d'impot",
                            hint: "Entrer le N° d'impot",
                            icon: Icons.info_outline,
                            controller: numImpotVehicule,
                            validatorInput: false,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "N° de moteur",
                            hint: "Entrer le N° de moteur",
                            icon: Icons.info_outline,
                            controller: numMoteurVehicule,
                            validatorInput: false,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "N° de Chassie",
                            hint: "Entrer le N° de Chassie",
                            icon: Icons.info_outline,
                            controller: numChassiVehicule,
                            validatorInput: false,
                          ),
                          SizedBox(height: 10),

                          TextFildComponent(
                            labeltext: "Année de fabrication",
                            hint: "Entrer Année de fabrication",
                            icon: Icons.calendar_month,
                            controller: dateFabrication,
                            validatorInput: false,
                            keyboardTypeNumber: true,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "Nom du propriétaire",
                            hint: "Entrer Nom du propriétaire",
                            icon: Icons.person,
                            controller: nomProprietaire,
                            validatorInput: true,
                          ),
                          SizedBox(height: 10),
                          TextFildComponent(
                            labeltext: "Adresse du propriétaire",
                            hint: "Entrer Adresse du propriétaire",
                            icon: Icons.location_on,
                            controller: adresseProprietaire,
                            validatorInput: true,
                          ),
                          SizedBox(height: 10),

                          TextFildComponent(
                            labeltext: "N° tél du propriétaire",
                            hint: "Entrer N° tél du propriétaire",
                            icon: Icons.call,
                            controller: contactProprietaire,
                            validatorInput: true,
                            keyboardTypeNumber: true,
                          ),

                          SizedBox(height: 10),
                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.domain,
                            items: typeorganisationList,
                            label: "Type d'organisation",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              typeorganisationList,
                              selectedTypeOrganisation,
                              "value",
                            ),

                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedTypeOrganisation = int.parse(
                                    value.toString(),
                                  );
                                  // sexe = value as TextEditingController;
                                });

                                fetchOrganisation(
                                  int.parse(
                                    selectedTypeOrganisation.toString(),
                                  ),
                                );
                              } else {}
                            },
                          ),
                          SizedBox(height: 10),
                          CustomDropdown(
                            validatorInput: true,
                            icon: Icons.home_filled,
                            items: organisationList,
                            label: "Organisation",
                            displayKey: "text",
                            valueKey: "value",
                            value: CallApi.getValidDropdownValue(
                              organisationList,
                              selectedOrganisation,
                              "value",
                            ),
                            onChanged: (value) {
                              if (value != null &&
                                  value.toString().isNotEmpty) {
                                setState(() {
                                  selectedOrganisation = int.tryParse(
                                    value.toString(),
                                  );
                                });
                              } else {}
                            },
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: size.width * 0.8,
                                padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                                child: TextFildComponent(
                                  labeltext: "Code ambassadeur",
                                  hint: "Entrer Code ambassadeur",
                                  icon: Icons.code,
                                  controller: codeAmbassadeur,
                                  validatorInput: true,
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: Button(
                                  label: "",
                                  press: () {
                                    if (codeAmbassadeur.text != "") {
                                      fetchcodeAmbassadeur(
                                        codeAmbassadeur.text.toString(),
                                      );
                                    } else {
                                      showSnackBar(
                                        context,
                                        "Veillez Entrer le code ambassadeur",
                                        'danger',
                                      );
                                    }
                                  },
                                  icon: Icons.verified_user_sharp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // TextFildComponent(
                          //   labeltext: "Ref ambassadeur",
                          //   hint: "Entrer Ref ambassadeur",
                          //   icon: Icons.key,
                          //   controller: refUser,
                          //   validatorInput: true,
                          //   enabledChamps: false,
                          // ),

                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
