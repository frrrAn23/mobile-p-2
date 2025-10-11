// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodie_app/main.dart';
import 'package:provider/provider.dart';
import 'package:foodie_app/recipe_provider.dart';

void main() {
  testWidgets('App shows app bar title', (WidgetTester tester) async {
    // Build our app with the provider (same as main.dart) and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RecipeProvider(),
        child: const RecipeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the app bar title is shown
    expect(find.text('Foodie Recipe Apps'), findsOneWidget);
  });
}
