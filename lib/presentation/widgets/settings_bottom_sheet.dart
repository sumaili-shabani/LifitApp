import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/providers/app_provider.dart';
import '../pages/change_password_page.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Language selector
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _LanguageChip(
                title: 'English',
                languageCode: 'en',
                isSelected: currentLocale.languageCode == 'en',
              ),
              _LanguageChip(
                title: 'Français',
                languageCode: 'fr',
                isSelected: currentLocale.languageCode == 'fr',
              ),
              _LanguageChip(
                title: 'Kiswahili',
                languageCode: 'sw',
                isSelected: currentLocale.languageCode == 'sw',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Theme selector
          Text(
            l10n.theme,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title:
                Text(themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) {
              ref.read(appThemeProvider.notifier).toggleTheme();
            },
            secondary: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LanguageChip extends ConsumerWidget {
  final String title;
  final String languageCode;
  final bool isSelected;

  const _LanguageChip({
    required this.title,
    required this.languageCode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilterChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          ref.read(appLocaleProvider.notifier).setLocale(languageCode);
        }
      },
      showCheckmark: false,
    );
  }
}
