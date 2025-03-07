class HistoriqueCourseModel {
  final int? id;
  final String? code;
  final int? refCourse;
  final int? refBanque;
  final int? montantPaie;
  final String? devise;
  final int? taux;
  final String? datePaie;
  final String? modepaie;
  final String? libellepaie;
  final String? numeroBordereau;
  final String? author;
  final int? refUser;
  final String? createdAt;
  final int? statutPayement;
  final int? refMode;
  final String? numerocompte;
  final String? nomMode;
  final String? nomBanque;
  final String? designation;
  final int? refPassager;
  final int? refConduite;
  final int? refTypeCourse;
  final dynamic refAdresseDepart;
  final dynamic refAdresseArrivee;
  final double? departLongitude;
  final double? departLatitude;
  final double? arriveeLongitude;
  final double? arriveeLatitude;
  final double? currentLongitude;
  final double? currentLatitude;
  final String? dateCourse;
  final String? status;
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
  final String? nomTypeCourse;
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

  HistoriqueCourseModel({
     this.id,
     this.code,
     this.refCourse,
     this.refBanque,
     this.montantPaie,
     this.devise,
     this.taux,
     this.datePaie,
     this.modepaie,
     this.libellepaie,
     this.numeroBordereau,
     this.author,
     this.refUser,
     this.createdAt,
     this.statutPayement,
     this.refMode,
     this.numerocompte,
     this.nomMode,
     this.nomBanque,
     this.designation,
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
     this.status,
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
     this.nomTypeCourse,
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
  });

  factory HistoriqueCourseModel.fromMap(Map<String, dynamic> json) =>
      HistoriqueCourseModel(
        id: json["id"],
        code: json["code"],
        refCourse: json["refCourse"],
        refBanque: json["refBanque"],
        montantPaie: json["montant_paie"],
        devise: json["devise"],
        taux: json["taux"],
        datePaie: json["date_paie"],
        modepaie: json["modepaie"],
        libellepaie: json["libellepaie"],
        numeroBordereau: json["numeroBordereau"],
        author: json["author"],
        refUser: json["refUser"],
        createdAt: json["created_at"],
        statutPayement: json["statutPayement"],
        refMode: json["refMode"],
        numerocompte: json["numerocompte"],
        nomMode: json["nom_mode"],
        nomBanque: json["nom_banque"],
        designation: json["designation"],
        refPassager: json["refPassager"],
        refConduite: json["refConduite"],
        refTypeCourse: json["refTypeCourse"],
        refAdresseDepart: json["refAdresseDepart"],
        refAdresseArrivee: json["refAdresseArrivee"],
        departLongitude: json["depart_longitude"].toDouble(),
        departLatitude: json["depart_latitude"].toDouble(),
        arriveeLongitude: json["arrivee_longitude"].toDouble(),
        arriveeLatitude: json["arrivee_latitude"].toDouble(),
        currentLongitude: json["current_longitude"].toDouble(),
        currentLatitude: json["current_latitude"].toDouble(),
        dateCourse: json["date_course"],
        status: json["status"],
        montantCourse: json["montant_course"],
        codeCourse: json["codeCourse"],
        latDepart: json["latDepart"].toDouble(),
        lonDepart: json["lonDepart"].toDouble(),
        latDestination: json["latDestination"].toDouble(),
        lonDestination: json["lonDestination"].toDouble(),
        nameDepart: json["nameDepart"],
        nameDestination: json["nameDestination"],
        distance: json["distance"].toDouble(),
        prixCourse: json["prixCourse"],
        nomTypeCourse: json["nomTypeCourse"],
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
        active: json["active"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "code": code,
    "refCourse": refCourse,
    "refBanque": refBanque,
    "montant_paie": montantPaie,
    "devise": devise,
    "taux": taux,
    "date_paie": datePaie,
    "modepaie": modepaie,
    "libellepaie": libellepaie,
    "numeroBordereau": numeroBordereau,
    "author": author,
    "refUser": refUser,
    "created_at": createdAt,
    "statutPayement": statutPayement,
    "refMode": refMode,
    "numerocompte": numerocompte,
    "nom_mode": nomMode,
    "nom_banque": nomBanque,
    "designation": designation,
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
    "status": status,
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
    "nomTypeCourse": nomTypeCourse,
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
    "active": active,
  };
}
