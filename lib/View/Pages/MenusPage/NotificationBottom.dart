import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/NotificationModel.dart';

class NotificationBottom extends StatefulWidget {
  const NotificationBottom({super.key});
  @override
   State<NotificationBottom> createState() => _NotificationBottomState();

}

class _NotificationBottomState extends State<NotificationBottom> {
  List<NotificationModel> notifications = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> deleteData(int id) async {
    try {
      final response = await CallApi.deleteData(
        "modible_delete_notification/${id.toInt()}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "Deleted!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction notification
      fetchNotifications();
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'chauffeur_mobile_notification/${userId.toInt()}',
      );
      setState(() {
        notifications =
            data.map((item) => NotificationModel.fromMap(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Container(
        height: MediaQuery.of(context).size.height * 0.50, // 75% de l'écran
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: [
              Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged:
                  (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                labelText: "Rechercher une notification...",
                prefixIcon: Icon(Icons.search),
                fillColor: theme.hoverColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                      final notification = notifications[index];
            
                      if (!notification.titreMessage.toLowerCase().contains(
                        searchQuery,
                      )) {
                        return Container();
                      }
            
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: Colors.blue,
                          ),
                          title: Text(
                            notification.titreMessage,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.messages),
                              Text(
                                "📅 ${CallApi.getFormatedDate(notification.createdAt)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.archive, color: Colors.red),
                            onPressed: () {
                              deleteData(notification.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
