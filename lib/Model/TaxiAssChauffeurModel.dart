class TaxiAssChauffeurModel {
  final int? id;
  final int? refChauffeur;
  final int? refVehicule;
  final String? status;
  final String? author;
  final int? refUser;
  final String? genreVehicule;
  final String? numPlaqueVehicule;
  final String? numChassiVehicule;
  final String? nomCouleur;
  final dynamic numMoteurVehicule;
  final dynamic dateFabrication;
  final int? refCouleur;
  final int? refCategorie;
  final dynamic numImpotVehicule;
  final String? nomProprietaire;
  final String? adresseProprietaire;
  final String? contactProprietaire;
  final int? refOrganisation;
  final dynamic numroIdentification;
  final String? nomCategorieVehicule;
  final int? refMarque;
  final String? nomMarque;
  final String? createdAt;
  final int? capo;
  final int? nbrPlace;
  final String? codeAmbassadeur;
  final String? imageVehicule;
  final String? fileVehicule;
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
  final String? avatar;
  final String? name;
  final String? email;
  final int? idRole;
  final String? roleName;
  final String? sexe;
  final String? telephone;
  final String? adresse;
  final int? active;
  final String? today;

  TaxiAssChauffeurModel({
    this.id,
    this.refChauffeur,
    this.refVehicule,
    this.status,
    this.author,
    this.refUser,
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
    this.avatar,
    this.name,
    this.email,
    this.idRole,
    this.roleName,
    this.sexe,
    this.telephone,
    this.adresse,
    this.active,
    this.today,
  });

  factory TaxiAssChauffeurModel.fromMap(Map<String, dynamic> json) =>
      TaxiAssChauffeurModel(
        id: json["id"],
        refChauffeur: json["refChauffeur"],
        refVehicule: json["refVehicule"],
        status: json["status"],
        author: json["author"],
        refUser: json["refUser"],
        genreVehicule: json["genreVehicule"],
        numPlaqueVehicule: json["numPlaqueVehicule"],
        numChassiVehicule: json["numChassiVehicule"],
        nomCouleur: json["nomCouleur"],
        numMoteurVehicule: json["numMoteurVehicule"],
        dateFabrication: json["dateFabrication"],
        refCouleur: json["refCouleur"],
        refCategorie: json["refCategorie"],
        numImpotVehicule: json["numImpotVehicule"],
        nomProprietaire: json["nomProprietaire"],
        adresseProprietaire: json["adresseProprietaire"],
        contactProprietaire: json["contactProprietaire"],
        refOrganisation: json["refOrganisation"],
        numroIdentification: json["numro_identification"],
        nomCategorieVehicule: json["nomCategorieVehicule"],
        refMarque: json["refMarque"],
        nomMarque: json["nomMarque"],
        createdAt: json["created_at"],
        capo: json["capo"],
        nbrPlace: json["nbrPlace"],
        codeAmbassadeur: json["codeAmbassadeur"],
        imageVehicule: json["imageVehicule"],
        fileVehicule: json["fileVehicule"],
        refTypeCourse: json["refTypeCourse"],
        detailCapo: json["detailCapo"],
        typeCarburant: json["typeCarburant"],
        nomTypeCourse: json["nomTypeCourse"],
        location: json["location"],
        imageTypeCourse: json["imageTypeCourse"],
        nomOrganisation: json["nom_organisation"],
        adresseOrganisation: json["adresse_organisation"],
        detailsOrganisation: json["details_organisation"],
        refTypeOrg: json["refTypeOrg"],
        nomTypeOrganisation: json["nom_type_organisation"],
        avatar: json["avatar"],
        name: json["name"],
        email: json["email"],
        idRole: json["id_role"],
        roleName: json["role_name"],
        sexe: json["sexe"],
        telephone: json["telephone"],
        adresse: json["adresse"],
        active: json["active"],
        today: json["today"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "refChauffeur": refChauffeur,
    "refVehicule": refVehicule,
    "status": status,
    "author": author,
    "refUser": refUser,
    "genreVehicule": genreVehicule,
    "numPlaqueVehicule": numPlaqueVehicule,
    "numChassiVehicule": numChassiVehicule,
    "nomCouleur": nomCouleur,
    "numMoteurVehicule": numMoteurVehicule,
    "dateFabrication": dateFabrication,
    "refCouleur": refCouleur,
    "refCategorie": refCategorie,
    "numImpotVehicule": numImpotVehicule,
    "nomProprietaire": nomProprietaire,
    "adresseProprietaire": adresseProprietaire,
    "contactProprietaire": contactProprietaire,
    "refOrganisation": refOrganisation,
    "numro_identification": numroIdentification,
    "nomCategorieVehicule": nomCategorieVehicule,
    "refMarque": refMarque,
    "nomMarque": nomMarque,
    "created_at": createdAt,
    "capo": capo,
    "nbrPlace": nbrPlace,
    "codeAmbassadeur": codeAmbassadeur,
    "imageVehicule": imageVehicule,
    "fileVehicule": fileVehicule,
    "refTypeCourse": refTypeCourse,
    "detailCapo": detailCapo,
    "typeCarburant": typeCarburant,
    "nomTypeCourse": nomTypeCourse,
    "location": location,
    "imageTypeCourse": imageTypeCourse,
    "nom_organisation": nomOrganisation,
    "adresse_organisation": adresseOrganisation,
    "details_organisation": detailsOrganisation,
    "refTypeOrg": refTypeOrg,
    "nom_type_organisation": nomTypeOrganisation,
    "avatar": avatar,
    "name": name,
    "email": email,
    "id_role": idRole,
    "role_name": roleName,
    "sexe": sexe,
    "telephone": telephone,
    "adresse": adresse,
    "active": active,
    "today": today,
  };
}
