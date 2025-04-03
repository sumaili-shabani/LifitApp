class ChauffeurListModel {
  final int? id;
  final String? name;
  final String? sexe;
  final String? telephone;
  final String? totalCountCourse;
  final String? lastActivity;
  final String? avatar;

  ChauffeurListModel({
    this.id,
    this.name,
    this.sexe,
    this.telephone,
    this.totalCountCourse,
    this.lastActivity,
    this.avatar,
  });

  factory ChauffeurListModel.fromMap(Map<String, dynamic> json) => ChauffeurListModel(
    id: json["id"],
    name: json["name"]?? '',
    sexe: json["sexe"]?? '',
    telephone: json["telephone"]??'',
    totalCountCourse: json["totalCountCourse"]??0,
    lastActivity: json["last_activity"] ?? '',
    avatar: json['avatar']??'',
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "sexe": sexe,
    "telephone": telephone,
    "totalCountCourse": totalCountCourse,
    "last_activity": lastActivity,
    'avatar': avatar,
  };
  
}
