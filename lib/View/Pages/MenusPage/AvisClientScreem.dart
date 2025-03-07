import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';

import 'package:lifti_app/Model/CourseModel.dart';

class AvisClientScreem extends StatefulWidget {
  const AvisClientScreem({super.key});
  @override
  State<AvisClientScreem> createState() => _AvisClientScreemState();
}

class _AvisClientScreemState extends State<AvisClientScreem> {
  List<CourseModel> notifications = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'chauffeur_mobile_commentaire_course_termine/${userId.toInt()}',
      );
      setState(() {
        notifications = data.map((item) => CourseModel.fromMap(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
          child: CircularProgressIndicator(),
        ) // Affiche un loader en attendant l'API
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Avis des clients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...notifications.map(
              (eval) => Card(
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: CallApi.getRandomColor(),
                    child: Text(CallApi.limitText(eval.namePassager!, 1)),
                    // backgroundImage: NetworkImage(
                    //   "${CallApi.fileUrl}/images/${order.avatarPassager}",
                    // ),
                  ),
                  title: Text(eval.namePassager!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          4,
                          (index) =>
                              Icon(Icons.star, color: Colors.orange, size: 18),
                        ),
                      ),
                      Text(eval.commentaires!, maxLines: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
  }
}
