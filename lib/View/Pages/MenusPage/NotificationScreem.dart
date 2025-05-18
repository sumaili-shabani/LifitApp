import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/NotificationModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
   State<NotificationsPage> createState() => _NotificationsPageState();

}

class _NotificationsPageState extends State<NotificationsPage> {
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              onChanged:
                  (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                labelText: "${l10n.notification_ui_recherche} ",
                prefixIcon: Icon(Icons.search),
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
