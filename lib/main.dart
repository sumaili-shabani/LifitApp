import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lifti_app/presentation/widgets/language_switch.dart';
import 'config/app_config.dart';
import 'core/di/service_locator.dart';
import 'app.dart';
import 'presentation/widgets/theme_switch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  await GetStorage.init();
  await setupServiceLocator();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: const [
          LanguageSwitch(),
          ThemeSwitch(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Rydex',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'Dark Mode Enabled'
                          : 'Light Mode Enabled',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
