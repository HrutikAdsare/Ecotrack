// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/screens/splash_screen.dart';

void main() {
  testWidgets('Splash Screen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(),
        routes: {
          '/signup': (context) => const Scaffold(body: Text("Sign Up Page")),
          '/login': (context) => const Scaffold(body: Text("Login Page")),
        },
      ),
    );

    expect(find.text("EcoTrack"), findsOneWidget);
    expect(find.text("Get Started"), findsOneWidget);
    expect(find.text("New User?"), findsOneWidget);
    expect(find.text("Log In"), findsOneWidget);

    await tester.tap(find.text("Get Started"));
    await tester.pumpAndSettle();
    expect(find.text("Sign Up Page"), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text("Log In"));
    await tester.pumpAndSettle();
    expect(find.text("Login Page"), findsOneWidget);
  });
}
