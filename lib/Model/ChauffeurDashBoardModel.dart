class ChauffeurDashBoardModel {
  final String? id;
  final int? sommePaiementBonus;
  final int? sommePaiementRecette;
  final int? sommePaiementCommission;
  final int? sommeRetrait;
  final int? sommeRecharge;
  final int? countCourse;
  final int? countCourseEncours;
  final int? countCourseTermine;
  final int? countRecharge;
  final int? sommePaiement;
  final int? sumMontantCourseEncours;
  final int? sumMontantCourseTermine;
  final double? sumDistanceCourseEncours;
  final double? sumDistanceCourseTermine;
  final int? countVoiture;
  final int? countPaiementSalaire;

  ChauffeurDashBoardModel({
    this.id,
    this.sommePaiementBonus,
    this.sommePaiementRecette,
    this.sommePaiementCommission,
    this.sommeRetrait,
    this.sommeRecharge,
    this.countCourse,
    this.countCourseEncours,
    this.countCourseTermine,
    this.countRecharge,
    this.sommePaiement,
    this.sumMontantCourseEncours,
    this.sumMontantCourseTermine,
    this.sumDistanceCourseEncours,
    this.sumDistanceCourseTermine,
    this.countVoiture,
    this.countPaiementSalaire,
  });

  factory ChauffeurDashBoardModel.fromMap(Map<String, dynamic> json) =>
      ChauffeurDashBoardModel(
        id: json["id"],
        sommePaiementBonus: json["SommePaiementBonus"],
        sommePaiementRecette: json["SommePaiementRecette"],
        sommePaiementCommission: json["SommePaiementCommission"],
        sommeRetrait: json["SommeRetrait"],
        sommeRecharge: json["SommeRecharge"],
        countCourse: json["CountCourse"],
        countCourseEncours: json["CountCourse_encours"],
        countCourseTermine: json["CountCourse_termine"],
        countRecharge: json["CountRecharge"],
        sommePaiement: json["SommePaiement"],
        sumMontantCourseEncours: json["SumMontantCourse_encours"],
        sumMontantCourseTermine: json["SumMontantCourse_termine"],
        sumDistanceCourseEncours: json["SumDistanceCourse_encours"].toDouble(),
        sumDistanceCourseTermine: json["SumDistanceCourse_termine"].toDouble(),

        countVoiture: json["CountVoiture"]??0,
        countPaiementSalaire: json["CountPaiementSalaire"]??0,
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "SommePaiementBonus": sommePaiementBonus,
    "SommePaiementRecette": sommePaiementRecette,
    "SommePaiementCommission": sommePaiementCommission,
    "SommeRetrait": sommeRetrait,
    "SommeRecharge": sommeRecharge,
    "CountCourse": countCourse,
    "CountCourse_encours": countCourseEncours,
    "CountCourse_termine": countCourseTermine,
    "CountRecharge": countRecharge,
    "SommePaiement": sommePaiement,
    "SumMontantCourse_encours": sumMontantCourseEncours,
    "SumMontantCourse_termine": sumMontantCourseTermine,
    "SumDistanceCourse_encours": sumDistanceCourseEncours,
    "SumDistanceCourse_termine": sumDistanceCourseTermine,
    "CountVoiture": countVoiture,
    "CountPaiementSalaire": countPaiementSalaire,
  };
}
