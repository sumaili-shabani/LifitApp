class PaiementCommissionModel {
  final int? id;
  final String? code;
  final int? refChauffeur;
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
  final String? avatarChauffeur;
  final String? nameChauffeur;
  final String? emailChauffeur;
  final int? idRoleChauffeur;
  final String? sexeChauffeur;
  final String? telephoneChauffeur;
  final String? adresseChauffeur;
  final int? activeChauffeur;
  final String? avatar;
  final String? name;
  final String? email;
  final int? idRole;
  final String? roleName;
  final String? sexe;
  final String? telephone;
  final String? adresse;
  final int? active;

  PaiementCommissionModel({
     this.id,
     this.code,
     this.refChauffeur,
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
     this.avatarChauffeur,
     this.nameChauffeur,
     this.emailChauffeur,
     this.idRoleChauffeur,
     this.sexeChauffeur,
     this.telephoneChauffeur,
     this.adresseChauffeur,
     this.activeChauffeur,
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

  factory PaiementCommissionModel.fromMap(Map<String, dynamic> json) =>
      PaiementCommissionModel(
        id: json["id"],
        code: json["code"],
        refChauffeur: json["refChauffeur"],
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
        avatarChauffeur: json["avatarChauffeur"],
        nameChauffeur: json["nameChauffeur"],
        emailChauffeur: json["emailChauffeur"],
        idRoleChauffeur: json["id_roleChauffeur"],
        sexeChauffeur: json["sexeChauffeur"],
        telephoneChauffeur: json["telephoneChauffeur"],
        adresseChauffeur: json["adresseChauffeur"],
        activeChauffeur: json["activeChauffeur"],
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
    "refChauffeur": refChauffeur,
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
    "avatarChauffeur": avatarChauffeur,
    "nameChauffeur": nameChauffeur,
    "emailChauffeur": emailChauffeur,
    "id_roleChauffeur": idRoleChauffeur,
    "sexeChauffeur": sexeChauffeur,
    "telephoneChauffeur": telephoneChauffeur,
    "adresseChauffeur": adresseChauffeur,
    "activeChauffeur": activeChauffeur,
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
