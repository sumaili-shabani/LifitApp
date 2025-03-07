class UserModel {
  final int? userId;
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
  final String?  createdAt;

  UserModel({
     this.userId,
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

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    userId: json["user_id"],
    avatar: json["avatar"],
    name: json["name"],
    email: json["email"],
    idRole: json["id_role"],
    roleName: json["role_name"],
    sexe: json["sexe"],
    telephone: json["telephone"],
    adresse: json["adresse"],
    active: json["active"],
    soldeCommission: json["solde_commission"].toDouble(),
    soldeRecette: json["solde_recette"].toDouble(),
    tel1: json["tel1"],
    tel2: json["tel2"],
    tel3: json["tel3"],
    tel4: json["tel4"],
    refBanque: json["refBanque"],
    soldeBonus: json["solde_bonus"].toDouble(),
    refMode: json["refMode"],
    numerocompte: json["numerocompte"],
    nomMode: json["nom_mode"],
    nomBanque: json["nom_banque"],
    designation: json["designation"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toMap() => {
    "user_id": userId,
    "avatar": avatar,
    "name": name,
    "email": email,
    "id_role": idRole,
    "role_name": roleName,
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
    "refMode": refMode,
    "numerocompte": numerocompte,
    "nom_mode": nomMode,
    "nom_banque": nomBanque,
    "designation": designation,
    "created_at": createdAt,
  };
}
