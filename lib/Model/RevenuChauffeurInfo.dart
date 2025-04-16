class ChauffeurInfoModel {
  final int? id;
  final int? nombreCourse;
  final String? nombreCourseRealise;
  final String? lastActivity;
  final String? timeAgo;
  final List<ChauffeurList>? chauffeurList;

  ChauffeurInfoModel({
    this.id,
    this.nombreCourse,
    this.nombreCourseRealise,
    this.lastActivity,
    this.timeAgo,
    this.chauffeurList,
  });

  factory ChauffeurInfoModel.fromMap(Map<String, dynamic> json) =>
      ChauffeurInfoModel(
        id: json["id"],
        nombreCourse: json["nombreCourse"],
        nombreCourseRealise: json["nombreCourseRealise"],
        lastActivity: json["last_activity"],
        timeAgo: json["timeAgo"],
        chauffeurList: List<ChauffeurList>.from(
          json["chauffeurList"].map((x) => ChauffeurList.fromMap(x)),
        ),
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "nombreCourse": nombreCourse,
    "nombreCourseRealise": nombreCourseRealise,
    "last_activity": lastActivity,
    "timeAgo": timeAgo,
    "chauffeurList": List<dynamic>.from(chauffeurList!.map((x) => x.toMap())),
  };
}

class ChauffeurList {
  final int? id;
  final String? name;
  final String? sexe;
  final String? telephone;
  final String? totalCountCourse;
  final String? lastActivity;

  ChauffeurList({
    this.id,
    this.name,
    this.sexe,
    this.telephone,
    this.totalCountCourse,
    this.lastActivity,
  });

  factory ChauffeurList.fromMap(Map<String, dynamic> json) => ChauffeurList(
    id: json["id"],
    name: json["name"],
    sexe: json["sexe"],
    telephone: json["telephone"],
    totalCountCourse: json["totalCountCourse"],
    lastActivity: json["last_activity"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "sexe": sexe,
    "telephone": telephone,
    "totalCountCourse": totalCountCourse,
    "last_activity": lastActivity,
  };
}
