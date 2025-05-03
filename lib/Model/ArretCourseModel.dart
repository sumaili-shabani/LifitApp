class ArretCourseModel {
  final int? id;
  final int? idCourse;
  final double? latArret;
  final double? lonArret;
  final String? nameLieu;
  final String? createdAt;

  ArretCourseModel({
    this.id,
    this.idCourse,
    this.latArret,
    this.lonArret,
    this.nameLieu,
    this.createdAt,
  });

  factory ArretCourseModel.fromMap(
    Map<String, dynamic> json,
  ) => ArretCourseModel(
    id: json["id"],
    idCourse: json["idCourse"],
    latArret: (json["latArret"] != null) ? json["latArret"].toDouble() : 0.0,
    lonArret: (json["lonArret"] != null) ? json["lonArret"].toDouble() : 0.0,
    nameLieu: json["nameLieu"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "idCourse": idCourse,
    "latArret": latArret,
    "lonArret": lonArret,
    "nameLieu": nameLieu,
    "created_at": createdAt,
  };
}
