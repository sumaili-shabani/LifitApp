import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/View/Pages/MenusPage/EditUserProfileScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/NotificationScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/UserProfileScreen.dart';
import 'package:lifti_app/presentation/pages/change_password_page.dart';
import 'package:lifti_app/presentation/pages/intro_page.dart';
import 'package:lifti_app/presentation/widgets/settings_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
 

  @override
  void initState() {
    super.initState();
  }

 

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profil du Chauffeur"),
          actions: [
             IconButton(
              onPressed: _showSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
            
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Profil"),
              Tab(icon: Icon(Icons.edit), text: "Editer"),
              Tab(icon: Icon(Icons.notifications), text: "Notifications"),
              Tab(icon: Icon(Icons.tune), text: "Paramètres"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserProfileScreen(),
            EditUserProfileScreen(),
        
            NotificationsPage(),
            // buildNotificationsTab(),
            // buildAppSettingsTab(),

             _buildPreferences(l10n),
          ],
        ),
      ),
    );
  }

 
  
  Widget buildNotificationsTab() {
    double _paddingValue = 10.0;
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      padding: EdgeInsets.all(_paddingValue),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ListView(
        padding: EdgeInsets.all(10),
        children: [
          ListTile(
            leading: Icon(Icons.notification_important, color: Colors.red),
            title: Text("Nouvelle course disponible"),
            subtitle: Text("Vous avez une nouvelle demande de course."),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text("Mise à jour du système"),
            subtitle: Text(
              "Une nouvelle version de l'application est disponible.",
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
          ),
        ],
      ),
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nameConnected');
    await prefs.remove('emailConnected');
    await prefs.remove('idRoleConnected');
    await prefs.remove('idConnected');
    await prefs.remove('userConnected');
    await prefs.remove('avatarConnected');
    await prefs.remove('token');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IntroPage()),
      (route) => false,
    );
  }

  Widget buildAppSettingsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Préférences de l'application",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text("Notifications"),
              subtitle: Text("Activer les notifications"),
              value: true,
              onChanged: (bool value) {},
            ),
            Divider(),
            Text(
              "Mode de paiement préféré",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: Text("Espèces"),
              value: "cash",
              groupValue: "cash",
              onChanged: (value) {},
            ),
            RadioListTile(
              title: Text("Carte bancaire"),
              value: "card",
              groupValue: "cash",
              onChanged: (value) {},
            ),
            RadioListTile(
              title: Text("Mobile Money"),
              value: "mobile_money",
              groupValue: "cash",
              onChanged: (value) {},
            ),
            Divider(),
            Text(
              "Thème de l'application",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text("Mode sombre"),
              value: false,
              onChanged: (bool value) {},
            ),
            Divider(),
            Text(
              "Langue de l'application",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: "Français",
              items: [
                DropdownMenuItem(child: Text("Français"), value: "Français"),
                DropdownMenuItem(child: Text("Anglais"), value: "Anglais"),
              ],
              onChanged: (String? value) {},
            ),
            Divider(),
            Text(
              "Confidentialité & Sécurité",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.red),
              title: Text("Changer le mot de passe"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.blue),
              title: Text("Politique de confidentialité"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.orange),
              title: Text("Déconnexion"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
    );
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

Widget _buildPreferences(AppLocalizations l10n) {
   
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        
        _buildPreferenceSection(
          l10n.notifications,
          [
            _buildSwitchTile(
              l10n.rideNotifications,
              true,
              (value) {},
            ),
            _buildSwitchTile(
              l10n.promotionsAndOffers,
              false,
              (value) {},
            ),
            _buildSwitchTile(
              l10n.news,
              true,
              (value) {},
            ),
          ],
        ),
        const Divider(),
        _buildPreferenceSection(
          l10n.privacy,
          [
            _buildSwitchTile(
              l10n.shareLocation,
              true,
              (value) {},
            ),
            _buildSwitchTile(
              l10n.rideHistory,
              true,
              (value) {},
            ),
          ],
        ),
        const Divider(),
        _buildPreferenceSection(
          l10n.payment,
          [
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text(l10n.paymentMethods),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Gérer les méthodes de paiement
                showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(l10n.paymentMethods),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile(
                            title: Text("Espèces"),
                            value: "cash",
                            groupValue: "cash",
                            onChanged: (value) {},
                          ),
                          RadioListTile(
                            title: Text("Carte bancaire"),
                            value: "card",
                            groupValue: "cash",
                            onChanged: (value) {},
                          ),
                          RadioListTile(
                            title: Text("Mobile Money"),
                            value: "mobile_money",
                            groupValue: "cash",
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.close),
                        ),
                      ],
                    ),
              );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: Text(l10n.automaticBilling),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Gérer les factures
              },
            ),
            
          ],
        ),
         const Divider(),
        _buildPreferenceSection(
          "Confidentialité & Sécurité", [
          ListTile(
            leading: Icon(Icons.lock, color: Colors.red),
            title: Text("Changer le mot de passe"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder:
                    (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const ChangePasswordPage(),
                    ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.blue),
            title: Text("Politique de confidentialité"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.orange),
            title: Text("Déconnexion"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              logout();
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildPreferenceSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

}
