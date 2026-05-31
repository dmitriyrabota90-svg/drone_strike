import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_locale_controller.dart';
import '../features/lives/domain/lives_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';

class DroneStrikeApp extends ConsumerWidget {
  const DroneStrikeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(appLocaleControllerProvider).asData?.value;
    ref.read(livesControllerProvider);

    return MaterialApp.router(
      title: 'FPV Last Run',
      debugShowCheckedModeBanner: false,
      locale: selectedLocale,
      routerConfig: createAppRouter(),
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
