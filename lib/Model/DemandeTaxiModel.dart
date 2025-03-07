class DemandeTaxiModel {
  final int id;
  final int statut;
  final double lat;
  final double lng;
  final int refPassager;
  final int refChauffeur;
  final String avatarPassager;
  final String namePassager;
  final String emailPassager;
  final int idRolePassager;
  final String roleNamePassager;
  final String sexePassager;
  final String telephonePassager;
  final String adressePassager;
  final int activePassager;
  final String avatarChauffeur;
  final String nameChauffeur;
  final String emailChauffeur;
  final int idRoleChauffeur;
  final String roleNameChauffeur;
  final String sexeChauffeur;
  final String telephoneChauffeur;
  final String adresseChauffeur;
  final int activeChauffeur;
  final String createdAt;

  DemandeTaxiModel({
    required this.id,
    required this.statut,
    required this.lat,
    required this.lng,
    required this.refPassager,
    required this.refChauffeur,
    required this.avatarPassager,
    required this.namePassager,
    required this.emailPassager,
    required this.idRolePassager,
    required this.roleNamePassager,
    required this.sexePassager,
    required this.telephonePassager,
    required this.adressePassager,
    required this.activePassager,
    required this.avatarChauffeur,
    required this.nameChauffeur,
    required this.emailChauffeur,
    required this.idRoleChauffeur,
    required this.roleNameChauffeur,
    required this.sexeChauffeur,
    required this.telephoneChauffeur,
    required this.adresseChauffeur,
    required this.activeChauffeur,
    required this.createdAt,
  });

  factory DemandeTaxiModel.fromMap(Map<String, dynamic> json) =>
      DemandeTaxiModel(
        id: json["id"],
        statut: json["statut"],
        lat: json["lat"].toDouble(),
        lng: json["lng"].toDouble(),
        refPassager: json["refPassager"],
        refChauffeur: json["refChauffeur"],
        avatarPassager: json["avatarPassager"],
        namePassager: json["namePassager"],
        emailPassager: json["emailPassager"],
        idRolePassager: json["id_rolePassager"],
        roleNamePassager: json["role_namePassager"],
        sexePassager: json["sexePassager"],
        telephonePassager: json["telephonePassager"],
        adressePassager: json["adressePassager"],
        activePassager: json["activePassager"],
        avatarChauffeur: json["avatarChauffeur"],
        nameChauffeur: json["nameChauffeur"],
        emailChauffeur: json["emailChauffeur"],
        idRoleChauffeur: json["id_roleChauffeur"],
        roleNameChauffeur: json["role_nameChauffeur"],
        sexeChauffeur: json["sexeChauffeur"],
        telephoneChauffeur: json["telephoneChauffeur"],
        adresseChauffeur: json["adresseChauffeur"],
        activeChauffeur: json["activeChauffeur"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "statut": statut,
    "lat": lat,
    "lng": lng,
    "refPassager": refPassager,
    "refChauffeur": refChauffeur,
    "avatarPassager": avatarPassager,
    "namePassager": namePassager,
    "emailPassager": emailPassager,
    "id_rolePassager": idRolePassager,
    "role_namePassager": roleNamePassager,
    "sexePassager": sexePassager,
    "telephonePassager": telephonePassager,
    "adressePassager": adressePassager,
    "activePassager": activePassager,
    "avatarChauffeur": avatarChauffeur,
    "nameChauffeur": nameChauffeur,
    "emailChauffeur": emailChauffeur,
    "id_roleChauffeur": idRoleChauffeur,
    "role_nameChauffeur": roleNameChauffeur,
    "sexeChauffeur": sexeChauffeur,
    "telephoneChauffeur": telephoneChauffeur,
    "adresseChauffeur": adresseChauffeur,
    "activeChauffeur": activeChauffeur,
    "created_at": createdAt,
  };
}
