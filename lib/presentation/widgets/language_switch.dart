import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';

class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: 'Change language',
      onSelected: (String languageCode) {
        ref.read(localeProvider.notifier).setLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'fr')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 8),
              const Text('Français'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sw',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'sw')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 8),
              const Text('Kiswahili'),
            ],
          ),
        ),
      ],
    );
  }
}
