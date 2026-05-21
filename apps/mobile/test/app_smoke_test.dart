import 'package:drone_strike/app/drone_strike_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app starts and shows main menu navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DroneStrikeApp()));

    expect(find.text('Drone Strike'), findsWidgets);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Main Menu'), findsOneWidget);
    expect(find.text('Level Select'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
  });
}
