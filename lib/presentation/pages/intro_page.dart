import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/View/Pages/AmbassadeurApp.dart';
import 'package:lifti_app/View/Pages/ChauffeurApp.dart';
import 'package:lifti_app/View/Pages/PassagerApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/settings_bottom_sheet.dart';
import 'login_page.dart';

class IntroPage extends ConsumerStatefulWidget {
  const IntroPage({super.key});

  @override
  ConsumerState<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends ConsumerState<IntroPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String avatarUser = "";
  String connected = "";
  int id = 0;
  int idRoleConnected = 0;
  int refConnected = 0;
  String emailConnected = "";

  Future getConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('nameConnected')!;
      id = localStorage.getInt('idConnected')!;
      idRoleConnected = localStorage.getInt('idRoleConnected')!;
      refConnected = localStorage.getInt('idConnected')!;
      emailConnected = localStorage.getString('emailConnected')!;
      avatarUser = localStorage.getString('avatarConnected')!;
    });

    print("connected $idRoleConnected");
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifie si la localisation est activée
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifie les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation ont été refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Les permissions de localisation sont définitivement refusées.',
      );
    }

    // Obtenir la position actuelle
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future getUserPosition() async {
    try {
      Position position = await _determinePosition();
      // print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      return position;
    } catch (e) {
      print("Erreur: $e");
    }
  }

  Future ChangeMyPosition() async {
    Position position = await getUserPosition();
    Map<String, dynamic> svData = {
      "id": refConnected.toInt(),
      "latUser": position.latitude,
      "lonUser": position.longitude,
    };

    final response = await CallApi.postData(
      "chauffeur_mobilechangePosition",
      svData,
    );
    final Map<String, dynamic> responseData = response;
    String message = responseData['data'] ?? "Données envoyées avec succès";

    // print(message);

    // print(svData);
  }

  @override
  void initState() {
    super.initState();

    getConnected();

    ChangeMyPosition();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == 7;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final pages = [
      _IntroPageItem(
        imagePath: "assets/images/car_2.png",
        title: l10n.introWelcomeTitle,
        description: l10n.introWelcomeDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/image_taxi_3.png",
        title: l10n.introBookingTitle,
        description: l10n.introBookingDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/tracking.png",
        title: l10n.introTrackingTitle,
        description: l10n.introTrackingDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/image_taxi_1.png",
        title: l10n.introNotifTitle,
        description: l10n.introNotifDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/image_taxi_2.png",
        title: l10n.introPaymentTitle,
        description: l10n.introPaymentDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/car_3.png",
        title: l10n.introReviewTitle,
        description: l10n.introReviewDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/car_1.png",
        title: l10n.introSupportTitle,
        description: l10n.introSupportDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      _IntroPageItem(
        imagePath: "assets/images/logoApp.png",
        title: l10n.introRewardsTitle,
        description: l10n.introRewardsDesc,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
    ];

    return idRoleConnected == 2
        ? AmbassadeurApp()
        : idRoleConnected == 3
        ? ChauffeurApp()
        : idRoleConnected == 4
        ? PassagerApp()
        : Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Settings button with rotation animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * 3.14159,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _showSettingsBottomSheet,
                    ),
                  );
                },
              ),
              // Skip button with fade animation
              if (!_isLastPage)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(l10n.introSkip),
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              // Background gradient animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.surface,
                    ],
                    stops: [0.0, 0.8],
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: pages,
                    ),
                  ),
                  // Bottom navigation with slide animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page indicator with scale animation
                          Row(
                            children: List.generate(
                              pages.length,
                              (index) => TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween(
                                  begin: 0.0,
                                  end: _currentPage == index ? 1.0 : 0.5,
                                ),
                                builder: (context, value, child) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    height: 8,
                                    width: _currentPage == index ? 24 : 8,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(value),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Next/Start button with scale animation
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween(begin: 0.8, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLastPage
                                          ? _navigateToLogin
                                          : () {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    _isLastPage
                                        ? l10n.introStart
                                        : l10n.introNext,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }
}

class _IntroPageItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _IntroPageItem({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.5, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Image.asset(
                          imagePath,
                          width: size.width * 0.9,
                          height: size.height * 0.5,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Animated title
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Animated description
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
