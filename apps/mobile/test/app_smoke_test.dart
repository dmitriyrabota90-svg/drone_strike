import 'package:drone_strike/app/drone_strike_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

Future<void> pumpDroneStrikeApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: DroneStrikeApp()));
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('app starts and main menu appears', (tester) async {
    await pumpDroneStrikeApp(tester);

    expect(find.text('Drone Strike'), findsWidgets);
    expect(find.text('Level Select'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
  });

  testWidgets('main menu hides Continue for a new guest', (tester) async {
    await pumpDroneStrikeApp(tester);

    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('login screen renders email and password fields', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('register screen renders legal checkboxes', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle();

    expect(find.text('I accept the terms of use'), findsOneWidget);
    expect(find.text('I accept personal data processing'), findsOneWidget);
    expect(find.text('I am at least 13 years old'), findsOneWidget);
  });

  testWidgets('profile screen renders guest state', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.ensureVisible(find.text('Profile'));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Guest mode'), findsOneWidget);
    expect(find.text('Login required'), findsOneWidget);
  });

  testWidgets('level select unlocks missions 1 and 2 for guest', (
    tester,
  ) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();

    expect(find.text('Mission 1'), findsOneWidget);
    expect(find.text('Mission 2'), findsOneWidget);
    expect(find.text('Mission 3'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('leaderboard screen requires login for guest', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.ensureVisible(find.text('Leaderboard'));
    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Login required to view leaderboard'), findsOneWidget);
  });

  testWidgets('game placeholder shows selected mission number', (tester) async {
    await pumpDroneStrikeApp(tester);

    await tester.tap(find.text('Level Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mission 2'));
    await tester.pumpAndSettle();

    expect(find.text('Mission 2'), findsWidgets);
    expect(find.text('Game screen placeholder'), findsOneWidget);
    expect(find.text('Simulate Mission Complete'), findsOneWidget);
  });

  testWidgets('settings screen renders sound legal and account sections', (
    tester,
  ) async {
    await pumpDroneStrikeApp(tester);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Legal Documents'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });
}
