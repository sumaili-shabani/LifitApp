class NotificationModel {
  final int id;
  final String titreMessage;
  final String messages;
  final String author;
  final int refUser;
  final String createdAt;
  final String avatar;
  final String name;
  final String email;
  final int idRole;
  final String sexe;
  final String telephone;
  final String adresse;
  final int active;
  final String roleName;

  NotificationModel({
    required this.id,
    required this.titreMessage,
    required this.messages,
    required this.author,
    required this.refUser,
    required this.createdAt,
    required this.avatar,
    required this.name,
    required this.email,
    required this.idRole,
    required this.sexe,
    required this.telephone,
    required this.adresse,
    required this.active,
    required this.roleName,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        titreMessage: json["titreMessage"],
        messages: json["messages"],
        author: json["author"],
        refUser: json["refUser"],
        createdAt: json["created_at"],
        avatar: json["avatar"],
        name: json["name"],
        email: json["email"],
        idRole: json["id_role"],
        sexe: json["sexe"],
        telephone: json["telephone"],
        adresse: json["adresse"],
        active: json["active"],
        roleName: json["role_name"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "titreMessage": titreMessage,
    "messages": messages,
    "author": author,
    "refUser": refUser,
    "created_at": createdAt,
    "avatar": avatar,
    "name": name,
    "email": email,
    "id_role": idRole,
    "sexe": sexe,
    "telephone": telephone,
    "adresse": adresse,
    "active": active,
    "role_name": roleName,
  };
}
