import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> correspondent;

  const ChatDetailPage({super.key, required this.correspondent});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<dynamic> listConversation = [
    {
      "id": 1,
      "sender_id": 27,
      "receiver_id": 30,
      "message": "Bonjour boss",
      "is_read": 0,
      "created_at": "2025-02-03",
      "sender": {
        "id": 27,
        "name": "Roger Admin",
        "avatar": "1737386203.png", // Image de l'avatar
      },
      "receiver": {
        "id": 30,
        "name": "Drey Mukuka",
        "avatar": "1740654256.png", // Image de l'avatar
      },
    },
    {
      "id": 2,
      "sender_id": 30,
      "receiver_id": 27,
      "message": "Oui bonjour ni sawa? miye niko bien!!!",
      "is_read": 1,
      "created_at": "2025-02-03",
      "sender": {
        "id": 30,
        "name": "Drey Mukuka",
        "avatar": "1740654256.png", // Image de l'avatar
      },
      "receiver": {
        "id": 27,
        "name": "Roger Admin",
        "avatar": "1737386203.png", // Image de l'avatar
      },
    },
  ];

  int currentUserId = 0; // ID de la personne connectée
  bool isLoading = true;
  int nombreMessageNonLit = 0;
  Future<void> fetchNotifications() async {
    int? userId = await CallApi.getUserId();
    // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    setState(() {
      currentUserId = userId;
    });
    try {
      List<dynamic> data = await CallApi.fetchListData(
        "mobile_show_message_sigle/${currentUserId.toString()}/${widget.correspondent['id']}",
      );

      // print(data);

      setState(() {
        listConversation = data;
        isLoading = false;
        nombreMessageNonLit = countUnreadMessages(30, data);
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      //mes scripts
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      try {
        Map<String, dynamic> svData = {
          "sender_id": userId,
          "receiver_id": widget.correspondent["id"],
          "message": messageController.text,
        };
        await CallApi.postData("mobile_insert_message", svData);

        await CallApi.fetchData(
          "mobile_make_read_message/${userId.toString()}",
        );

        // print(responseChangeStatut);

        // final Map<String, dynamic> responseData = responseChangeStatut;
        // String message = responseData['data'] ?? "Message!!!";
        // showSnackBar(context, message, 'success');

        fetchNotifications();
      } catch (e) {
        showSnackBar(context, e.toString(), 'success');
        print(e.toString());
      }
      //fin scripts

      setState(() {
        messageController.clear();
      });
    }
  }

  int countUnreadMessages(int userId, List<dynamic> listConversation) {
    return listConversation
        .where((msg) => msg["receiver_id"] == userId && msg["is_read"] == 0)
        .length;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Row(
          children: [
            // Avatar de la personne connectée
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  "${CallApi.fileUrl}/images/${widget.correspondent['avatar'] ?? 'avatar.png'}",
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            SizedBox(width: 10),
            // Nom de la personne connectée
            Text(
              widget.correspondent["name"] ??
                  "Inconnu", // Remplacer par le nom dynamique
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),

        actions: [
           IconButton(
            onPressed: () {
              fetchNotifications();
            },
            icon: Icon(Icons.refresh,  color: Colors.white),
            tooltip: "${l10n.chat_ui_synchroniser}",
          ),
          // Icone des notifications avec badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.message,  color: Colors.white,
                ), // Icône de message
                onPressed: () {
                  // Action lors du clic sur les notifications
                },
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
                    nombreMessageNonLit
                        .toString(), // Remplacer par le nombre de notifications non lues
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: listConversation.length,
                      itemBuilder: (context, index) {
                        final chat = listConversation[index];
                        bool isSentByMe = chat["sender_id"] == currentUserId;
                        String time = DateFormat(
                          'HH:mm',
                        ).format(DateTime.parse(chat["created_at"]));

                        return Align(
                          alignment:
                              isSentByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isSentByMe ? Colors.green : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  chat["message"] ?? "",
                                  style: TextStyle(
                                    color:
                                        isSentByMe
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      CallApi.getFormatedDate(
                                        chat["created_at"],
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      chat["is_read"] == 1
                                          ? Icons.done_all
                                          : Icons.check,
                                      size: 16,
                                      color:
                                          chat["is_read"] == 1
                                              ? Colors.blue
                                              : Colors.white,
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              hintText: "${l10n.chat_ui_taper_messager}",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.green),
                          onPressed: sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  
}
