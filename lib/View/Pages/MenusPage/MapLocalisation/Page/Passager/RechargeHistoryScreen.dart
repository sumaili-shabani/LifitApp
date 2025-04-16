import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:http/http.dart' as http;

class RechargeHistoryScreen extends StatefulWidget {
  const RechargeHistoryScreen({super.key});

  @override
  State<RechargeHistoryScreen> createState() => _RechargeHistoryScreenState();
}

class _RechargeHistoryScreenState extends State<RechargeHistoryScreen> {
  List<dynamic> payments = [];

  List<dynamic> filteredPayments = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  int idRole = 0;

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
      'chauffeur_mobile_historique_recharge_solde/${userId.toString()}',
    );

    // print(infoData);

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body)['data'];
      // print(data);
      setState(() {
        idRole = roleId!;
        payments = infoData;
        filteredPayments = infoData;
        isLoading = false;
      });
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  void filterTargets(String query) {
    setState(() {
      filteredPayments =
          payments
              .where(
                (target) =>
                    (target["date_paie"]?.toString() ?? "")
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    (target["designation"]?.toString() ?? "")
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    (target["montant_paie"]?.toString() ?? "").contains(
                      query, // Pas besoin de `.toLowerCase()` pour un montant numérique
                    ),
              )
              .toList();
    });
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
            onChanged: filterTargets,
            decoration: InputDecoration(
              hintText: "Rechercher un paiement...",
              fillColor: theme.hoverColor,
              prefixIcon: Icon(Icons.search),
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
                itemCount: filteredPayments.length,
                itemBuilder: (context, index) {
                  var payment = filteredPayments[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "${CallApi.fileUrl}/images/${payment['avatarChauffeur']}",
                        ),
                      ),
                      title: Text(
                        payment["nameChauffeur"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${payment["montant_paie"]} ${payment["devise"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    CallApi.getFormatedDate(
                                      payment["date_paie"],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 5),
                              Text("Code: ${payment["code"]}"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 5),
                              Text("Banque: ${payment["nom_banque"]}"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Colors.red),
                              SizedBox(width: 5),
                              Text(" ${payment["telephoneChauffeur"]}"),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(
                        payment["statutPayement"] == 1
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            payment["statutPayement"] == 1
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}
