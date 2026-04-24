import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:techpie/main.dart';

void main() {
  testWidgets('App shell renders with navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(const TechPieApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Schedule'), findsWidgets);
    expect(find.text('Assignments'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Navigation switches pages', (WidgetTester tester) async {
    await tester.pumpWidget(const TechPieApp());

    // Starts on Home
    expect(find.text('Welcome to TechPie'), findsOneWidget);

    // Tap Schedule — now shows timetable grid with sample courses
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.today), findsOneWidget);
    expect(find.text('植物保护学通论(B)'), findsOneWidget);

    // Tap Assignments
    await tester.tap(find.text('Assignments'));
    await tester.pumpAndSettle();
    expect(find.text('No assignments yet'), findsOneWidget);

    // Tap Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
  });
}
