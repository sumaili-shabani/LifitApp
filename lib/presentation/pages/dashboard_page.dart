import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifti_app/presentation/pages/profile_page.dart';
import '../widgets/animated_nav_bar.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../../core/statement/auth/auth_bloc.dart';
import 'map_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is AuthSuccess ? state.user.name : 'Guest';

        final List<Widget> pages = [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar with Profile and Settings
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcome,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _showSettings,
                              icon: const Icon(Icons.settings_outlined),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                // TODO: Show notifications
                              },
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = 3; // Navigate to profile tab
                                });
                              },
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.colorScheme.primary,
                                backgroundImage: null,
                                child: Text(
                                  userName.substring(0, 1),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dashboardQuickActions,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickAction(
                                  context,
                                  Icons.directions_car_outlined,
                                  l10n.dashboardBookRide,
                                  () {
                                    setState(() {
                                      _selectedIndex =
                                          1; // Navigate to rides tab
                                    });
                                  },
                                ),
                                _buildQuickAction(
                                  context,
                                  Icons.history_outlined,
                                  l10n.dashboardHistory,
                                  () {
                                    // TODO: Navigate to history
                                  },
                                ),
                                _buildQuickAction(
                                  context,
                                  Icons.wallet_outlined,
                                  l10n.dashboardWallet,
                                  () {
                                    setState(() {
                                      _selectedIndex =
                                          2; // Navigate to wallet tab
                                    });
                                  },
                                ),
                                _buildQuickAction(
                                  context,
                                  Icons.support_agent_outlined,
                                  l10n.dashboardSupport,
                                  () {
                                    // TODO: Navigate to support
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recent Rides
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dashboardRecentRides,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3, // Show last 3 rides
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                title: Text('Course #${1000 + index}'),
                                subtitle: Text('20 janvier 2025'),
                                trailing: Text(
                                  '${15 + index} €',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  // TODO: Show ride details
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Promotions
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dashboardPromotions,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(right: 16),
                                child: Container(
                                  width: size.width * 0.8,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${l10n.dashboardDiscount} ${(index + 1) * 10}%',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            l10n.dashboardPromoDescription,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.colorScheme.onPrimary
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // TODO: Apply promotion
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.onPrimary,
                                          foregroundColor:
                                              theme.colorScheme.primary,
                                        ),
                                        child: Text(l10n.dashboardApplyPromo),
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
                  ),
                ],
              ),
            ),
          ),
          // const MapPage(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 48),
                const SizedBox(height: 16),
                Text(l10n.dashboardWallet),
              ],
            ),
          ),
          const ProfilePage(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 48),
                const SizedBox(height: 16),
                Text(l10n.dashboardProfile),
              ],
            ),
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: AnimatedNavBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
               
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.dashboardHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.directions_car_outlined),
                selectedIcon: const Icon(Icons.directions_car),
                label: l10n.dashboardRides,
              ),
              NavigationDestination(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: const Icon(Icons.account_balance_wallet),
                label: l10n.dashboardWallet,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.dashboardProfile,
              ),
            ],
          ),
        );
      },
    );
  }
}
