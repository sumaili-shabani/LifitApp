import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/StatJourRevenuModel.dart';

class StatistiqueJour extends StatefulWidget {
  const StatistiqueJour({super.key});

  @override
  State<StatistiqueJour> createState() => _StatistiqueJourState();
}

class _StatistiqueJourState extends State<StatistiqueJour> {
  final String dateDuJour = DateFormat('dd/MM/yyyy').format(DateTime.now());

  List<StatJourRevenuModel> notifications = [];

  bool isLoading = true;

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'chauffeur_mobile_stat_paiement_course_date/${userId.toInt()}',
      );
   
      // print(dataDash);

      setState(() {
        notifications =
            data.map((item) => StatJourRevenuModel.fromMap(item)).toList();

        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return // Promotions
    Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Revenu du mois en cours",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var course = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: size.width * 0.8,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.error,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Statistiques du Jour",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: theme.indicatorColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.indicatorColor,
                                        ),
                                      ),
                                      Spacer(),

                                      Text(
                                        CallApi.getFormatedDate(
                                          course.category.toString(),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.indicatorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.card_giftcard,
                                        color: theme.indicatorColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Revenu du jour",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.indicatorColor,
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet_sharp,
                                            color: theme.indicatorColor,
                                            size: 20,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "${course.value.toString()} CDF",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: theme.indicatorColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
