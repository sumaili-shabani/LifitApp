import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/ArretCourseModel.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

class ArretListWidget extends StatefulWidget {
  final CourseInfoPassagerModel course;
  final bool etatSuppression;
  const ArretListWidget({
    super.key,
    required this.course,
    required this.etatSuppression,
  });

  @override
  State<ArretListWidget> createState() => _ArretListWidgetState();
}

class _ArretListWidgetState extends State<ArretListWidget> {
  bool isLoading = true;
  List<ArretCourseModel> arretList = [];

  Future<void> fetchArret() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        "get_arret_course/${widget.course.id}",
      );
      // print("data: $data");
      setState(() {
        arretList = data.map((item) => ArretCourseModel.fromMap(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  void _deleteArret(int index) async {
    int arret = index;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer ce lieu ?'),
            content: const Text('Cette action est irréversible. Continuer ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // widget.onDeleteArret(arret);
      Navigator.pop(context);
      deleteData(arret);
    }
  }

  /// 🔹 **Méthode ETIQUETER LE LIEU**
  Future<void> showEditLieuDialog({
    required BuildContext context,
    required ArretCourseModel arret,
    required Function(String newNameLieu) onEdit,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: arret.nameLieu,
    );

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Étiqueter le lieu'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Entrez un nouveau nom pour le lieu',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                onEdit(controller.text.trim());
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Éditer le lieu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConfigurationApp.successColor,
              ),
            ),
          ],
        );
      },
    );
  }

  etiqueterNameArretCourse(int id, String nameLieu) async {
    try {
      Map<String, dynamic> svData = {"id": id, "nameLieu": nameLieu};

      print("svData: $svData");

      final response = await CallApi.insertData(
        endpoint: "etiqueterNameArretCourse",
        data: svData,
      );
      if (response['data'] != "") {
        // print(response['data']);
        // Navigator.pop(context);
        showSnackBar(context, response['data'].toString(), "success");
        fetchArret();
      }
    } catch (e) {
      showSnackBar(context, e.toString(), "danger");
      print(e.toString());
    }
  }

  /// 🔹 **Méthode DELETE**
  Future<void> deleteData(int id) async {
    try {
      final response = await CallApi.deleteData(
        "delete_arret_vehicule/${id.toInt()}}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "Deleted!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction demande
      fetchArret();
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchArret();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.drag_handle, color: Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(
                'Liste des Arrêts (Course)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: arretList.length,
                  itemBuilder: (context, index) {
                    final arret = arretList[index];
                    final createdAt =
                        DateTime.tryParse(arret.createdAt.toString()) ??
                        DateTime.now();
                    final formattedTime = DateFormat(
                      'dd/MM/yyyy à HH:mm:ss ',
                    ).format(createdAt);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.green.shade50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          arret.nameLieu.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lat: ${arret.latArret}, Lon: ${arret.lonArret}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ajouté le : $formattedTime',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing:
                            widget.etatSuppression
                                ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'tag') {
                                      // Action pour étiqueter
                                      print(
                                        'Étiqueter lieu : ${arret.nameLieu}',
                                      );
                                    } else if (value == 'delete') {
                                      _deleteArret(arret.id!);
                                    }
                                  },
                                  icon: const Icon(Icons.more_vert),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          onTap: () {
                                            showEditLieuDialog(
                                              context: context,
                                              arret: arret,
                                              onEdit: (newName) {
                                                //  print(newName);
                                                // Tu peux aussi appeler une API ici si nécessaire
                                                etiqueterNameArretCourse(
                                                  arret.id!,
                                                  newName,
                                                );
                                              },
                                            );
                                          },
                                          value: 'tag',
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.label_outline,
                                                color: Colors.deepPurple,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Étiqueter le lieu'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () {
                                            _deleteArret(arret.id!);
                                          },
                                          value: 'delete',
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Supprimer'),
                                            ],
                                          ),
                                        ),
                                      ],
                                )
                                : SizedBox(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
  }
}
