class VoitureModel {
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

  VoitureModel({
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

  factory VoitureModel.fromMap(Map<String, dynamic> json) => VoitureModel(
    id: json["id"],
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
    author: json["author"],
    refUser: json["refUser"],
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
  );

  Map<String, dynamic> toMap() => {
    "id": id,
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
    "author": author,
    "refUser": refUser,
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
  };
}
