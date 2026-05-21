import 'package:go_router/go_router.dart';

import '../features/achievements/presentation/achievements_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/game/presentation/game_placeholder_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/legal/presentation/legal_documents_screen.dart';
import '../features/level_select/presentation/level_select_screen.dart';
import '../features/main_menu/presentation/main_menu_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shop/presentation/shop_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/levels',
        builder: (context, state) => const LevelSelectScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/legal',
        builder: (context, state) => const LegalDocumentsScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GamePlaceholderScreen(),
      ),
    ],
  );
}
