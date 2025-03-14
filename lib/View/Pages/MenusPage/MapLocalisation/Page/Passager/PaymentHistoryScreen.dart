import 'package:flutter/material.dart';
import 'package:lifti_app/core/theme/app_theme.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> paymentHistory;
  final String searchQuery;
  const PaymentHistoryScreen({
    super.key,
    required this.paymentHistory,
    required this.searchQuery,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
   var filteredList =
        widget.paymentHistory.where((item) {
          String searchLower = widget.searchQuery.toLowerCase();
          String chauffeur = item["chauffeur"].toString().toLowerCase();
          String date = item["date"].toString().toLowerCase();
          String course = item["course"].toString().toLowerCase();

          return chauffeur.contains(searchLower) || date.contains(searchLower) ||  course.contains(searchLower);
        }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Image.asset('assets/images/1.png',),
            ),
            title: Text(
              item["chauffeur"],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Course: ${item["course"]}"),
                Text("Véhicule: ${item["vehicule"]}"),
                Text("Départ: ${item["depart"] ?? 'Non précisé'}"),
                Text("Destination: ${item["destination"]}"),
                Text("Paiement: ${item["mode"]}"),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item["montant"]} CDF",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "${item["date"]}",
                  style: TextStyle(color: AppTheme.lightGreen, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
