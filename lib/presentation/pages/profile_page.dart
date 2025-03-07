import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/models/auth.dart';
import '../../core/statement/auth/auth_bloc.dart';
import 'change_password_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.profile),
              actions: [
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.profileUpdated)),
                          );
                        }
                      }
                    });
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.information),
                  Tab(text: l10n.history),
                  Tab(text: l10n.settings),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileInfo(l10n, user),
                _buildRideHistory(l10n),
                _buildPreferences(l10n),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildProfileInfo(AppLocalizations l10n, Datum user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: _isValidAvatarUrl(user.avatar)
                        ? NetworkImage(user.avatar)
                        : null,
                    child: !_isValidAvatarUrl(user.avatar)
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name.split(" ")[0][0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildRatingBar(),
            const SizedBox(height: 24),
            _buildTextField(
              l10n.fullName,
              user.name,
              Icons.person,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.email,
              user.email,
              Icons.email,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.phoneNumber,
              user.telephone,
              Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.homeAddress,
              user.adresse,
              Icons.home,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              l10n.workAddress,
              user.adresse,
              Icons.work,
              enabled: _isEditing,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.favoriteLocations,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text('Aéroport de Goma'),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {},
                ),
                Chip(
                  label: Text('Marché Central'),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {},
                ),
                Chip(
                  label: Text('Université de Goma'),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {},
                ),
              ],
            ),
            if (_isEditing)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.addFavoriteLocation),
                onPressed: () {
                  // TODO: Implémenter l'ajout de lieu favori
                },
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogout());
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isValidAvatarUrl(String? url) {
    if (url == null || url.isEmpty || url == "null") return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildRatingBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '4.8',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(width: 8),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 24),
            Icon(Icons.star, color: Colors.amber, size: 24),
            Icon(Icons.star, color: Colors.amber, size: 24),
            Icon(Icons.star, color: Colors.amber, size: 24),
            Icon(Icons.star_half, color: Colors.amber, size: 24),
          ],
        ),
        SizedBox(width: 8),
        Text(
          '(42 courses)',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildRideHistory(AppLocalizations l10n) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '-1.6803, 29.2367 → -1.6780, 29.2260',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pierre Dubois • Toyota Corolla'),
                const Text(
                  '25.0 \$ • 2023-03-01 12:00:00',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const Text('5.0'),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.rideDetails),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nom du conducteur: Pierre Dubois'),
                      const Text('Véhicule: Toyota Corolla'),
                      const Text('Prix: 25.0 \$'),
                      const Text('Évaluation: 5.0/5'),
                      const Text('Statut: Terminé'),
                      const Text('Date: 2023-03-01 12:00:00'),
                      const SizedBox(height: 8),
                      const Text('Point de départ et de destination'),
                      const Text('Point de départ: -1.6803, 29.2367'),
                      const Text('Point de destination: -1.6780, 29.2260'),
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
        );
      },
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
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.changePassword),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const ChangePasswordPage(),
                  ),
                );
              },
            )
          ],
        ),
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
