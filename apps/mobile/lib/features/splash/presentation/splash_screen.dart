import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/menu_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go('/menu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MenuBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) {
                return Opacity(
                  opacity: scale.clamp(0.0, 1.0),
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.logo, height: 170, fit: BoxFit.contain),
                  const SizedBox(height: 14),
                  Text(
                    l10n.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 96,
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
