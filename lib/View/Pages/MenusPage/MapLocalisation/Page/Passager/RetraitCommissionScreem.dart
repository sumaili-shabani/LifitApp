import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:http/http.dart' as http;
import 'package:lifti_app/Model/PaiementCommissionModel.dart';

class RetraitCommissionScreem extends StatefulWidget {
  const RetraitCommissionScreem({super.key});

  @override
  State<RetraitCommissionScreem> createState() =>
      _RetraitCommissionScreemState();
}

class _RetraitCommissionScreemState extends State<RetraitCommissionScreem> {
  List<PaiementCommissionModel> targets = [];
  bool isLoading = true;
  int idRole = 0;

  List<PaiementCommissionModel> filteredTargets = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  Future<void> fetchData() async {
    int? roleId = await CallApi.getUserRole();
    int? userId = await CallApi.getUserId();

    final response = await http.get(
      Uri.parse(
        '${CallApi.baseUrl.toString()}/user_mobile_info/${userId.toString()}',
      ),
      headers: await CallApi.getHeaders(),
    );

    List<dynamic> infoData = await CallApi.fetchListData(
      'passager_paiement_commission_all/${userId.toString()}',
    );

    // print(infoData);

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body)['data'];
      // print(data);
      setState(() {
        idRole = roleId!;
        targets =
            infoData
                .map((item) => PaiementCommissionModel.fromMap(item))
                .toList();
        ;
        filteredTargets = targets;
        isLoading = false;
      });
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged:
                (value) => setState(() => searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Rechercher un paiement...",
              prefixIcon: Icon(Icons.search),
              fillColor: theme.hoverColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
              child: ListView.builder(
                itemCount: filteredTargets.length,
                itemBuilder: (context, index) {
                  var paiement = filteredTargets[index];

                  if (!paiement.designation!.toLowerCase().contains(
                        searchQuery,
                      ) &&
                      !paiement.datePaie!.toLowerCase().contains(searchQuery) &&
                      !paiement.nomBanque!.toLowerCase().contains(
                        searchQuery,
                      ) &&
                      !paiement.montantPaie!.toString().toLowerCase().contains(
                        searchQuery,
                      )) {
                    return Container();
                  }
                  return Card(
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
                  );
                },
              ),
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
