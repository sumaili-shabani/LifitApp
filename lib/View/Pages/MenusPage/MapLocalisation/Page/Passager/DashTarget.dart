import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashtargetChauffeur extends StatefulWidget {
  const DashtargetChauffeur({super.key});

  @override
  State<DashtargetChauffeur> createState() => _DashtargetChauffeurState();
}

class _DashtargetChauffeurState extends State<DashtargetChauffeur> {
  bool isLoading = true;
  int idRole = 0;
  // Liste des paiements
  List<dynamic> payments = [];

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
      'chauffeur_dashbord_journalier/${userId.toString()}',
    );

    // print(infoData);

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body)['data'];
      // print(data);
      setState(() {
        idRole = roleId!;
        payments = infoData;
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return CardSoldeChauffeur(payment: payments[index]);
      },
    );
  }
}

class CardSoldeChauffeur extends StatelessWidget {
  final Map<String, dynamic> payment;
  const CardSoldeChauffeur({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    List<dynamic> paymentModes = payment["payementMode"];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : Total Courses & Somme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "${l10n.info_menu_ui_total_course} : ${payment["countcourse_to_day"]} ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${l10n.info_menu_ui_tot} : ${NumberFormat("#,###").format(payment["sumcourse_to_day"])} CDF",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 5),
    
            // Liste des modes de paiement
            Column(
              children:
                  paymentModes
                      .map((mode) => _buildPaymentItem(context, mode))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour un mode de paiement
  Widget _buildPaymentItem(BuildContext context, Map<String, dynamic> mode) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _getPaymentIcon(mode["designation"]),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode["designation"],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ConfigurationApp.successColor,
                  ),
                ),
                Text(
                  "${l10n.info_menu_ui_montant}: ${NumberFormat("#,###").format(mode["montant_paie"])} ${mode["devise"]}",
                  style: TextStyle(fontSize: 14,),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM yyyy').format(DateTime.parse(mode["date_paie"])),
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Sélection de l'icône selon le mode de paiement
  Widget _getPaymentIcon(String designation) {
    IconData icon;
    switch (designation.toLowerCase()) {
      case "cash":
        icon = Icons.attach_money;
        break;
      case "mobile money":
        icon = Icons.phone_iphone;
        break;
      case "banque":
        icon = Icons.account_balance;
        break;
      default:
        icon = Icons.payment;
    }
    return CircleAvatar(
      backgroundColor: ConfigurationApp.successColor,
      radius: 20,
      child: Icon(icon, color: Colors.white),
    );
  }
}
