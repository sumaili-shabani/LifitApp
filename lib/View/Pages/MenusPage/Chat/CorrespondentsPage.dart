import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/ChatDetailPage.dart';
import 'package:lifti_app/presentation/widgets/settings_bottom_sheet.dart';

class CorrespondentsPage extends StatefulWidget {
  const CorrespondentsPage({super.key});

  @override
  State<CorrespondentsPage> createState() => _CorrespondentsPageState();
}

class _CorrespondentsPageState extends State<CorrespondentsPage> {
  List<dynamic> correspondents = [
    {
      "id": 1,
      "name": "Roger Admin",
      "avatar": "1737386203.png",
      "last_message": "Bonjour boss",
      "last_message_date": "2025-03-08 10:15",
      "unread_count": 2,
    },
  ];

  List<dynamic> filteredCorrespondents = [];
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté

    int? userRole = await CallApi.getUserRole();
    if (userId == null || userRole == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
     
      if(userRole == 2){
        List<dynamic> data = await CallApi.fetchListData(
          'mobile_ambassadeur_show_user_list_message/${userId.toString()}',
        );

         setState(() {
          correspondents = data;
          filteredCorrespondents = data;
          isLoading = false;
        });

        // print(data);
      }else if (userRole==3) {

        List<dynamic> data = await CallApi.fetchListData(
          'mobile_show_user_list_message/${userId.toString()}',
        );
         setState(() {
          correspondents = data;
          filteredCorrespondents = data;
          isLoading = false;
        });
        
      }else if(userRole == 4){
        List<dynamic> data = await CallApi.fetchListData(
          'mobile_passager_show_user_list_message/${userId.toString()}',
        );

         setState(() {
          correspondents = data;
          filteredCorrespondents = data;
          isLoading = false;
        });

        // print(data);
      } else {
         List<dynamic> data = await CallApi.fetchListData(
          'mobile_show_user_list_message/${userId.toString()}',
        );

         setState(() {
          correspondents = data;
          filteredCorrespondents = data;
          isLoading = false;
        });
      }
      

      // print(data);

     
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

  void filterCorrespondents(String query) {
    final filtered =
        correspondents.where((correspondent) {
          return correspondent['name'].toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();

    setState(() {
      filteredCorrespondents = filtered;
    });
  }

  /*
*
*===========================
* Autres informations
*===========================
*
*/

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text(
          "Correspondants",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.message), // Icône de message
                onPressed: () {
                  // Action lors du clic sur les notifications
                },
                color: Colors.white,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    filteredCorrespondents.length
                        .toString(), // Remplacer par le nombre de notifications non lues
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_outlined),
            color: Colors.white,
          ),
        
        ],

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterCorrespondents,
              decoration: InputDecoration(
                // label: Text("Rechercher un correspondant"),
                hintText: "Rechercher un correspondant...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: Icon(Icons.search),
                filled: true,
                
              ),
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : ListView.builder(
                itemCount: filteredCorrespondents.length,
                itemBuilder: (context, index) {
                  final correspondent = filteredCorrespondents[index];
                  String time = DateFormat(
                    'HH:mm',
                  ).format(DateTime.parse(correspondent["last_message_date"]));

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              "${CallApi.fileUrl}/images/${correspondent['avatar']}",
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        title: Text(
                          correspondent["name"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(correspondent["last_message"]),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (correspondent["unread_count"] > 0)
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${correspondent["unread_count"]}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            SizedBox(height: 5),
                            Text(
                              '${CallApi.getFormatedDate(CallApi.limitText(correspondent["last_message_date"], 10))} ${time.toString()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatDetailPage(
                                    correspondent: correspondent,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
    );
  }

 
}
