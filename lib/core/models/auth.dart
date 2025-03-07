import 'package:meta/meta.dart';
import 'dart:convert';

class ModelLogin {
  final List<Datum> data;

  ModelLogin({
    required this.data,
  });

  factory ModelLogin.fromRawJson(String str) =>
      ModelLogin.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ModelLogin.fromJson(Map<String, dynamic> json) => ModelLogin(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  final int userId;
  final String avatar;
  final String name;
  final String email;
  final int idRole;
  final String roleName;
  final String sexe;
  final String telephone;
  final String adresse;
  final int active;

  Datum({
    required this.userId,
    required this.avatar,
    required this.name,
    required this.email,
    required this.idRole,
    required this.roleName,
    required this.sexe,
    required this.telephone,
    required this.adresse,
    required this.active,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
      );

  Map<String, dynamic> toJson() => {
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
      };
}
