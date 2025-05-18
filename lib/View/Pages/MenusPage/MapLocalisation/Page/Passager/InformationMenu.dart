import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/DashTarget.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PassagerHistoriqueCourse.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/RechargeHistoryScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/RetraitCommissionScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/TargetListScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InformationMenuScreem extends StatefulWidget {
  const InformationMenuScreem({super.key});

  @override
  State<InformationMenuScreem> createState() => _InformationMenuScreemState();
}

class _InformationMenuScreemState extends State<InformationMenuScreem> {
  int idRole = 0;
  getRoleConnected() async {
    int? roleId = await CallApi.getUserRole();
    setState(() {
      idRole = roleId!;
    });
  }

  @override
  void initState() {
    super.initState();
    getRoleConnected();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: Text(
            "${l10n.info_menu_ui_info}",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.chat, color: Colors.white),
              tooltip: "${l10n.map_client_discussion}",
              onPressed: () {
                Navigator.of(
                  context,
                ).push(AnimatedPageRoute(page: CorrespondentsPage()));
              },
            ),
            idRole == 3
                ? Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_money, color: Colors.white),
                      tooltip: "${l10n.info_menu_ui_show_stat}",
                      onPressed: () {
                        showFinanceBottomSheet(context, idRole);
                      },
                    ),
                    
                  ],
                )
                : SizedBox(),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            ButtonsTabBar(
              backgroundColor: ConfigurationApp.successColor,
              unselectedBackgroundColor: Colors.grey[300],
              unselectedLabelStyle: TextStyle(color: Colors.black),
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  text: "${l10n.info_menu_ui_target_course}",
                  icon: Icon(Icons.card_giftcard, size: 17),
                ),
                Tab(
                  text: idRole == 3 ? "${l10n.info_menu_ui_historique_recharge}" : "${l10n.info_menu_ui_mes_paiement}",
                  icon: Icon(Icons.receipt_long_sharp, size: 17),
                ),
                Tab(
                  text: "${l10n.info_menu_ui_paiement_commission}",
                  icon: Icon(Icons.credit_card, size: 17),
                ),
                
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TargetListScreen(),
                  idRole == 3
                      ? RechargeHistoryScreen()
                      : PassagerHistoriqueCourse(),

                  RetraitCommissionScreem(),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFinanceBottomSheet(BuildContext context, int idRole) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet d'occuper un pourcentage de l'écran
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // 50% de la hauteur de l'écran
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, size: 17),
                          SizedBox(width: 5),
                          Text(
                            "${l10n.info_menu_ui_portefueil}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                             
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "${l10n.info_menu_ui_solde_actuel}",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.timer, size: 15, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                idRole == 3
                    ? Expanded(child: DashtargetChauffeur())
                    : SizedBox(height: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}
