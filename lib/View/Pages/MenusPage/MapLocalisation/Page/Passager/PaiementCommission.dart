import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/PaiementCommissionModel.dart';


class PaiementCommission extends StatefulWidget {
  const PaiementCommission({super.key});
  @override
  State<PaiementCommission> createState() => _PaiementCommissionState();
}

class _PaiementCommissionState extends State<PaiementCommission> {
  List<PaiementCommissionModel> notifications = [];
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
        'passager_paiement_commission/${userId.toInt()}',
      );
      setState(() {
        notifications = data.map((item) => PaiementCommissionModel.fromMap(item)).toList();
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
    return isLoading
        ? Center(
          child: CircularProgressIndicator(),
        ) // Affiche un loader en attendant l'API
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                "Paiement Commission",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            ...notifications.map(
              (paiement) => Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // ✅ Photo de la personne payée
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          '${CallApi.fileUrl}/images/${paiement.avatarChauffeur}', // URL de l'image
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),

                      // ✅ Infos sur le paiement
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paiement.nameChauffeur!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Montant : ${paiement.montantPaie} CDF",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            _buildPaymentTag(paiement.designation!),
                            
                          ],
                        ),
                      ),

                      // ✅ Date de paiement
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: theme.hintColor,
                                size: 15,
                              ),
                              SizedBox(width: 1),
                              Text(
                                " ${CallApi.getFormatedDate(paiement.datePaie.toString())}",
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )

            ),
          ],
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
