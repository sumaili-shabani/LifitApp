class ConducteurModel {
  final int? id;
  final int? refChauffeur;
  final int? refVehicule;
  final String? status;
  final String? author;
  final int? refUser;
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
  final String? createdAt;
  final String? nomCouleur;
  final String? avatar;
  final String? name;
  final String? email;
  final int? idRole;
  final String? sexe;
  final String? telephone;
  final String? adresse;
  final int? active;
  final int? soldeCommission;
  final int? soldeRecette;
  final String? tel1;
  final String? tel2;
  final String? tel3;
  final String? tel4;
  final int? refBanque;
  final int? soldeBonus;
  final dynamic? codePromoUser;
  final String? nom;
  final String? roleName;
  final int? refMode;
  final String? numerocompte;
  final String? nomMode;
  final String? nomBanque;
  final String? designation;

  ConducteurModel({
    this.id,
    this.refChauffeur,
    this.refVehicule,
    this.status,
    this.author,
    this.refUser,
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
    this.createdAt,
    this.nomCouleur,
    this.avatar,
    this.name,
    this.email,
    this.idRole,
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
    this.codePromoUser,
    this.nom,
    this.roleName,
    this.refMode,
    this.numerocompte,
    this.nomMode,
    this.nomBanque,
    this.designation,
  });

  factory ConducteurModel.fromMap(Map<String, dynamic> json) => ConducteurModel(
    id: json["id"],
    refChauffeur: json["refChauffeur"],
    refVehicule: json["refVehicule"],
    status: json["status"],
    author: json["author"],
    refUser: json["refUser"],
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
    createdAt: json["created_at"],
    nomCouleur: json["nomCouleur"],
    avatar: json["avatar"],
    name: json["name"],
    email: json["email"],
    idRole: json["id_role"],
    sexe: json["sexe"],
    telephone: json["telephone"],
    adresse: json["adresse"],
    active: json["active"],
    soldeCommission: json["solde_commission"],
    soldeRecette: json["solde_recette"],
    tel1: json["tel1"],
    tel2: json["tel2"],
    tel3: json["tel3"],
    tel4: json["tel4"],
    refBanque: json["refBanque"],
    soldeBonus: json["solde_bonus"],
    codePromoUser: json["codePromoUser"],
    nom: json["nom"],
    roleName: json["role_name"],
    refMode: json["refMode"],
    numerocompte: json["numerocompte"],
    nomMode: json["nom_mode"],
    nomBanque: json["nom_banque"],
    designation: json["designation"],
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
    "created_at": createdAt,
    "nomCouleur": nomCouleur,
    "avatar": avatar,
    "name": name,
    "email": email,
    "id_role": idRole,
    "sexe": sexe,
    "telephone": telephone,
    "adresse": adresse,
    "active": active,
    "solde_commission": soldeCommission,
    "solde_recette": soldeRecette,
    "tel1": tel1,
    "tel2": tel2,
    "tel3": tel3,
    "tel4": tel4,
    "refBanque": refBanque,
    "solde_bonus": soldeBonus,
    "codePromoUser": codePromoUser,
    "nom": nom,
    "role_name": roleName,
    "refMode": refMode,
    "numerocompte": numerocompte,
    "nom_mode": nomMode,
    "nom_banque": nomBanque,
    "designation": designation,
  };
}
