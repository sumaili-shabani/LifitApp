class CourseInfoPassagerModel {
  final int? id;
  final int? refPassager;
  final int? refConduite;
  final int? refTypeCourse;
  final String? refAdresseDepart;
  final String? refAdresseArrivee;
  final double? departLongitude;
  final double? departLatitude;
  final double? arriveeLongitude;
  final double? arriveeLatitude;
  final double? currentLongitude;
  final double? currentLatitude;
  final String? dateCourse;
  final String? devise;
  final int? taux;
  final String? status;
  final String? author;
  final int? refUser;
  final String? createdAt;
  final int? montantCourse;
  final String? codeCourse;
  final double? latDepart;
  final double? lonDepart;
  final double? latDestination;
  final double? lonDestination;
  final String? nameDepart;
  final String? nameDestination;
  final double? distance;
  final int? prixCourse;
  final String? timeEst;
  final dynamic calculate;
  final dynamic commentaires;
  final String? nomTypeCourse;
  final String? location;
  final int? refChauffeur;
  final int? refVehicule;
  final String? genreVehicule;
  final String? numPlaqueVehicule;
  final String? numChassiVehicule;
  final String? numMoteurVehicule;
  final String? dateFabrication;
  final int? refCouleur;
  final int? refCategorie;
  final String? numImpotVehicule;
  final String? nomProprietaire;
  final String? adresseProprietaire;
  final String? contactProprietaire;
  final String? nomCategorieVehicule;
  final int? refMarque;
  final String? nomMarque;
  final String? nomCouleur;
  final String? avatarChauffeur;
  final String? nameChauffeur;
  final String? emailChauffeur;
  final int? idRoleChauffeur;
  final String? sexeChauffeur;
  final String? telephoneChauffeur;
  final String? adresseChauffeur;
  final int? activeChauffeur;
  final String? avatarPassager;
  final String? namePassager;
  final String? emailPassager;
  final int? idRolePassager;
  final String? sexePassager;
  final String? telephonePassager;
  final String? adressePassager;
  final int? activePassager;
  final String? avatar;
  final String? name;
  final String? email;
  final int? idRole;
  final String? roleName;
  final String? sexe;
  final String? telephone;
  final String? adresse;
  final int? active;
  final String? imageTypeCourse;

  final String? dateLimiteCourse;
  final String? timePlus;
  final double? taxeSuplementaire;
  final int? rating;
  final int? arret;

  CourseInfoPassagerModel({
    this.id,
    this.refPassager,
    this.refConduite,
    this.refTypeCourse,
    this.refAdresseDepart,
    this.refAdresseArrivee,
    this.departLongitude,
    this.departLatitude,
    this.arriveeLongitude,
    this.arriveeLatitude,
    this.currentLongitude,
    this.currentLatitude,
    this.dateCourse,
    this.devise,
    this.taux,
    this.status,
    this.author,
    this.refUser,
    this.createdAt,
    this.montantCourse,
    this.codeCourse,
    this.latDepart,
    this.lonDepart,
    this.latDestination,
    this.lonDestination,
    this.nameDepart,
    this.nameDestination,
    this.distance,
    this.prixCourse,
    this.timeEst,
    this.calculate,
    this.commentaires,
    this.nomTypeCourse,
    this.location,
    this.refChauffeur,
    this.refVehicule,
    this.genreVehicule,
    this.numPlaqueVehicule,
    this.numChassiVehicule,
    this.numMoteurVehicule,
    this.dateFabrication,
    this.refCouleur,
    this.refCategorie,
    this.numImpotVehicule,
    this.nomProprietaire,
    this.adresseProprietaire,
    this.contactProprietaire,
    this.nomCategorieVehicule,
    this.refMarque,
    this.nomMarque,
    this.nomCouleur,
    this.avatarChauffeur,
    this.nameChauffeur,
    this.emailChauffeur,
    this.idRoleChauffeur,
    this.sexeChauffeur,
    this.telephoneChauffeur,
    this.adresseChauffeur,
    this.activeChauffeur,
    this.avatarPassager,
    this.namePassager,
    this.emailPassager,
    this.idRolePassager,
    this.sexePassager,
    this.telephonePassager,
    this.adressePassager,
    this.activePassager,
    this.avatar,
    this.name,
    this.email,
    this.idRole,
    this.roleName,
    this.sexe,
    this.telephone,
    this.adresse,
    this.active,
    this.imageTypeCourse,

    this.dateLimiteCourse,
    this.taxeSuplementaire,
    this.timePlus,
    this.rating,
    this.arret,
  });

  factory CourseInfoPassagerModel.fromMap(
    Map<String, dynamic> json,
  ) => CourseInfoPassagerModel(
    id: json["id"],
    refPassager: json["refPassager"],
    refConduite: json["refConduite"],
    refTypeCourse: json["refTypeCourse"],
    refAdresseDepart: json["refAdresseDepart"],
    refAdresseArrivee: json["refAdresseArrivee"],

    dateCourse: json["date_course"],
    devise: json["devise"],
    taux: json["taux"],
    status: json["status"],
    author: json["author"],
    refUser: json["refUser"],
    createdAt: json["created_at"],
    montantCourse: json["montant_course"],
    codeCourse: json["codeCourse"],
    departLongitude:
        (json["depart_longitude"] != null)
            ? json["depart_longitude"].toDouble()
            : 0.0,
    departLatitude:
        (json["depart_latitude"] != null)
            ? json["depart_latitude"].toDouble()
            : 0.0,
    arriveeLongitude:
        (json["arrivee_longitude"] != null)
            ? json["arrivee_longitude"].toDouble()
            : 0.0,
    arriveeLatitude:
        (json["arrivee_latitude"] != null)
            ? json["arrivee_latitude"].toDouble()
            : 0.0,
    currentLongitude:
        (json["current_longitude"] != null)
            ? json["current_longitude"].toDouble()
            : 0.0,
    currentLatitude:
        (json["current_latitude"] != null)
            ? json["current_latitude"].toDouble()
            : 0.0,
    latDepart: (json["latDepart"] != null) ? json["latDepart"].toDouble() : 0.0,
    lonDepart: (json["lonDepart"] != null) ? json["lonDepart"].toDouble() : 0.0,
    latDestination:
        (json["latDestination"] != null)
            ? json["latDestination"].toDouble()
            : 0.0,
    lonDestination:
        (json["lonDestination"] != null)
            ? json["lonDestination"].toDouble()
            : 0.0,
    distance: (json["distance"] != null) ? json["distance"].toDouble() : 0.0,
    taxeSuplementaire:
        (json["taxeSuplementaire"] != null)
            ? json["taxeSuplementaire"].toDouble()
            : 0.0,
    nameDepart: json["nameDepart"],
    nameDestination: json["nameDestination"],

    prixCourse: json["prixCourse"],
    timeEst: json["timeEst"],
    calculate: json["calculate"],
    commentaires: json["commentaires"],
    nomTypeCourse: json["nomTypeCourse"],
    location: json["location"],
    refChauffeur: json["refChauffeur"],
    refVehicule: json["refVehicule"],
    genreVehicule: json["genreVehicule"],
    numPlaqueVehicule: json["numPlaqueVehicule"],
    numChassiVehicule: json["numChassiVehicule"],
    numMoteurVehicule: json["numMoteurVehicule"],
    dateFabrication: json["dateFabrication"],
    refCouleur: json["refCouleur"],
    refCategorie: json["refCategorie"],
    numImpotVehicule: json["numImpotVehicule"],
    nomProprietaire: json["nomProprietaire"],
    adresseProprietaire: json["adresseProprietaire"],
    contactProprietaire: json["contactProprietaire"],
    nomCategorieVehicule: json["nomCategorieVehicule"],
    refMarque: json["refMarque"],
    nomMarque: json["nomMarque"],
    nomCouleur: json["nomCouleur"],
    avatarChauffeur: json["avatarChauffeur"],
    nameChauffeur: json["nameChauffeur"],
    emailChauffeur: json["emailChauffeur"],
    idRoleChauffeur: json["id_roleChauffeur"],
    sexeChauffeur: json["sexeChauffeur"],
    telephoneChauffeur: json["telephoneChauffeur"],
    adresseChauffeur: json["adresseChauffeur"],
    activeChauffeur: json["activeChauffeur"],
    avatarPassager: json["avatarPassager"],
    namePassager: json["namePassager"],
    emailPassager: json["emailPassager"],
    idRolePassager: json["id_rolePassager"],
    sexePassager: json["sexePassager"],
    telephonePassager: json["telephonePassager"],
    adressePassager: json["adressePassager"],
    activePassager: json["activePassager"],
    avatar: json["avatar"],
    name: json["name"],
    email: json["email"],
    idRole: json["id_role"],
    roleName: json["role_name"],
    sexe: json["sexe"],
    telephone: json["telephone"],
    adresse: json["adresse"],
    imageTypeCourse: json["imageTypeCourse"],

    timePlus: json["timePlus"],
    rating: json["rating"],
    dateLimiteCourse: json["dateLimiteCourse"],

    active: json["active"],
    arret: json["arret"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "refPassager": refPassager,
    "refConduite": refConduite,
    "refTypeCourse": refTypeCourse,
    "refAdresseDepart": refAdresseDepart,
    "refAdresseArrivee": refAdresseArrivee,
    "depart_longitude": departLongitude,
    "depart_latitude": departLatitude,
    "arrivee_longitude": arriveeLongitude,
    "arrivee_latitude": arriveeLatitude,
    "current_longitude": currentLongitude,
    "current_latitude": currentLatitude,
    "date_course": dateCourse,
    "devise": devise,
    "taux": taux,
    "status": status,
    "author": author,
    "refUser": refUser,
    "created_at": createdAt,
    "montant_course": montantCourse,
    "codeCourse": codeCourse,
    "latDepart": latDepart,
    "lonDepart": lonDepart,
    "latDestination": latDestination,
    "lonDestination": lonDestination,
    "nameDepart": nameDepart,
    "nameDestination": nameDestination,
    "distance": distance,
    "prixCourse": prixCourse,
    "timeEst": timeEst,
    "calculate": calculate,
    "commentaires": commentaires,
    "nomTypeCourse": nomTypeCourse,
    "location": location,
    "refChauffeur": refChauffeur,
    "refVehicule": refVehicule,
    "genreVehicule": genreVehicule,
    "numPlaqueVehicule": numPlaqueVehicule,
    "numChassiVehicule": numChassiVehicule,
    "numMoteurVehicule": numMoteurVehicule,
    "dateFabrication": dateFabrication,
    "refCouleur": refCouleur,
    "refCategorie": refCategorie,
    "numImpotVehicule": numImpotVehicule,
    "nomProprietaire": nomProprietaire,
    "adresseProprietaire": adresseProprietaire,
    "contactProprietaire": contactProprietaire,
    "nomCategorieVehicule": nomCategorieVehicule,
    "refMarque": refMarque,
    "nomMarque": nomMarque,
    "nomCouleur": nomCouleur,
    "avatarChauffeur": avatarChauffeur,
    "nameChauffeur": nameChauffeur,
    "emailChauffeur": emailChauffeur,
    "id_roleChauffeur": idRoleChauffeur,
    "sexeChauffeur": sexeChauffeur,
    "telephoneChauffeur": telephoneChauffeur,
    "adresseChauffeur": adresseChauffeur,
    "activeChauffeur": activeChauffeur,
    "avatarPassager": avatarPassager,
    "namePassager": namePassager,
    "emailPassager": emailPassager,
    "id_rolePassager": idRolePassager,
    "sexePassager": sexePassager,
    "telephonePassager": telephonePassager,
    "adressePassager": adressePassager,
    "activePassager": activePassager,
    "avatar": avatar,
    "name": name,
    "email": email,
    "id_role": idRole,
    "role_name": roleName,
    "sexe": sexe,
    "telephone": telephone,
    "adresse": adresse,
    "imageTypeCourse": imageTypeCourse,
    "active": active,
    "taxeSuplementaire": taxeSuplementaire,
    "timePlus": timePlus,
    "dateLimiteCourse": dateLimiteCourse,
    "rating": rating,
  };
}
