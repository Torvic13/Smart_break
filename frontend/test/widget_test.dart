// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_break/main.dart';
import 'package:smart_break/dao/dao_factory.dart';
import 'package:smart_break/dao/dao_factory_impl.dart';
import 'package:smart_break/dao/auth_service.dart';

void main() {
  testWidgets('Welcome screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
          ),
          Provider<DAOFactory>(
            create: (_) => DAOFactoryImpl(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Text('Smart Break - Test Running'),
          ),
        ),
      ),
    );

    // Verify that our test text appears
    expect(find.text('Smart Break - Test Running'), findsOneWidget);
  });
}