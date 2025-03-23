import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lifti_app/main.dart';
import 'core/providers/app_provider.dart';
import 'core/di/bloc_providers.dart';
import 'presentation/pages/intro_page.dart';
import 'config/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MultiBlocProvider(
      providers: [
        ...BlocProviders.providers,
      ],
      child: MaterialApp(
        title: 'SwiftRide',
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: appSupportedLocales,
        debugShowCheckedModeBanner: false,
        home: const IntroPage(),
        builder: EasyLoading.init(), // 🔥 IMPORTANT : Init ici !
        routes: _registerRoutes(),
      ),
    );
  }



  Map<String, WidgetBuilder> _registerRoutes() {
    return {
      '/home': (context) => const HomePage(),
      // Ajoutez d'autres routes ici
    };
  }
}
