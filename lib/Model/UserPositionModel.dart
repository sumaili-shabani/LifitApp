class UserPositionModel {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? password;
  final String? telephone;
  final String? adresse;
  final String? avatar;
  final String? sexe;
  final int? idRole;
  final double? soldeCommission;
  final double? soldeRecette;
  final int? active;
  final String? rememberToken;
  final String? createdAt;
  final String? updatedAt;
  final double? latUser;
  final double? lonUser;
  final String? tel1;
  final String? tel2;
  final String? tel3;
  final String? tel4;
  final int? refBanque;
  final double? soldeBonus;
  final dynamic codePromoUser;
  final String? lastActivity;

  UserPositionModel({
     this.id,
     this.name,
     this.email,
     this.emailVerifiedAt,
     this.password,
     this.telephone,
     this.adresse,
     this.avatar,
     this.sexe,
     this.idRole,
     this.soldeCommission,
     this.soldeRecette,
     this.active,
     this.rememberToken,
     this.createdAt,
     this.updatedAt,
     this.latUser,
     this.lonUser,
     this.tel1,
     this.tel2,
     this.tel3,
     this.tel4,
     this.refBanque,
     this.soldeBonus,
     this.codePromoUser,
     this.lastActivity,
  });

  factory UserPositionModel.fromMap(Map<String, dynamic> json) =>
      UserPositionModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        password: json["password"],
        telephone: json["telephone"],
        adresse: json["adresse"],
        avatar: json["avatar"],
        sexe: json["sexe"],
        idRole: json["id_role"],
        soldeCommission: json["solde_commission"].toDouble(),
        soldeRecette: json["solde_recette"].toDouble(),
        active: json["active"],
        rememberToken: json["remember_token"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        latUser: json["latUser"].toDouble(),
        lonUser: json["lonUser"].toDouble(),
        tel1: json["tel1"],
        tel2: json["tel2"],
        tel3: json["tel3"],
        tel4: json["tel4"],
        refBanque: json["refBanque"],
        soldeBonus: json["solde_bonus"].toDouble(),
        codePromoUser: json["codePromoUser"],
        lastActivity: json["last_activity"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "password": password,
    "telephone": telephone,
    "adresse": adresse,
    "avatar": avatar,
    "sexe": sexe,
    "id_role": idRole,
    "solde_commission": soldeCommission,
    "solde_recette": soldeRecette,
    "active": active,
    "remember_token": rememberToken,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "latUser": latUser,
    "lonUser": lonUser,
    "tel1": tel1,
    "tel2": tel2,
    "tel3": tel3,
    "tel4": tel4,
    "refBanque": refBanque,
    "solde_bonus": soldeBonus,
    "codePromoUser": codePromoUser,
    "last_activity": lastActivity,
  };
}
