import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/HistoriqueCourseModel.dart';

class PassagerHistoriqueCourse extends StatefulWidget {
  const PassagerHistoriqueCourse({super.key});

  @override
  State<PassagerHistoriqueCourse> createState() =>
      _PassagerHistoriqueCourseState();
}

class _PassagerHistoriqueCourseState extends State<PassagerHistoriqueCourse> {
  TextEditingController searchController = TextEditingController();

  List<HistoriqueCourseModel> notifications = [];
  List<ChauffeurDashBoardModel> dashInfo = [];

  String searchQuery = "";
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'passager_mobile_fetch_paiement_course/${userId.toInt()}',
      );
      List<dynamic> dataDash = await CallApi.fetchListData(
        'passager_mobile_dashboard/${userId.toInt()}',
      );

      // print(dataDash);

      setState(() {
        notifications =
            data.map((item) => HistoriqueCourseModel.fromMap(item)).toList();
        dashInfo =
            dataDash
                .map((item) => ChauffeurDashBoardModel.fromMap(item))
                .toList();

        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // Barre d'en-tête
          // Center(
          //   child: Container(
          //     width: 50,
          //     height: 5,
          //     decoration: BoxDecoration(
          //       color: Colors.grey[400],
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 15),
          TextField(
            decoration: InputDecoration(
              labelText: "Rechercher une course",
              hintText: "Recherche une course...",
              fillColor: theme.hoverColor,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged:
                (value) => setState(() => searchQuery = value.toLowerCase()),
          ),
          SizedBox(height: 10),
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var course = notifications[index];
                    if (!course.namePassager!.toLowerCase().contains(
                          searchQuery,
                        ) &&
                        !course.datePaie!.toLowerCase().contains(searchQuery) &&
                        !course.nameChauffeur!.toLowerCase().contains(
                          searchQuery,
                        ) &&
                        !course.nameDepart!.toLowerCase().contains(
                          searchQuery,
                        ) &&
                        !course.nameDestination!.toLowerCase().contains(
                          searchQuery,
                        ) &&
                        !course.montantPaie!.toString().toLowerCase().contains(
                          searchQuery,
                        )) {
                      return Container();
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    "${CallApi.fileUrl}/images/${course.avatarPassager ?? 'avatar.png'}",
                                  ),
                                  radius: 25,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.namePassager!.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${course.distance!} Km - ${course.timeEst}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    Text(
                                      "${course.montantCourse!.toString()}CDF",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    _buildPaymentTag(course.designation!),
                                  ],
                                ),
                              ],
                            ),
                            Divider(height: 20, thickness: 1),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.green),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text("Départ : ${course.nameDepart!}"),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.flag, color: Colors.red),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "Arrivée : ${course.nameDestination!}",
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.car_crash, color: theme.hintColor),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "Type de course : ${course.nomTypeCourse!}",
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: theme.hintColor,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "Date : ${CallApi.getFormatedDate(course.datePaie.toString())}",
                                    style: TextStyle(color: theme.hintColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPaymentTag(String paymentMode) {
    IconData icon;
    Color color;

    switch (paymentMode) {
      case "Mobile Money":
        icon = Icons.smartphone;
        color = Colors.orange;
        break;
      case "Espèces" || "Cash":
        icon = Icons.money;
        color = Colors.green;
        break;
      case "Carte Bancaire":
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      default:
        icon = Icons.payment;
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 5),
        Text(
          paymentMode,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
