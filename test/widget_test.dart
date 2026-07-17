// Basic smoke test for the Medical Request Voice App.
//
// Verifies that the app boots and shows the loading screen or
// license activation screen on first launch.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medical_request_app/main.dart';

void main() {
  testWidgets('App boots and renders MaterialApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicalRequestApp());

    // The app should render a MaterialApp (loading screen initially).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
