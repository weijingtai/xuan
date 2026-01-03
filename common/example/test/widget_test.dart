// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';

import 'package:common/database/app_database.dart';
import 'package:common/pages/four_zhu_edit_page.dart';

void main() {
  testWidgets('FourZhuEditPage smoke test', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory(), false);
    addTearDown(() async => db.close());

    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      Provider<AppDatabase>.value(
        value: db,
        child: const MaterialApp(home: FourZhuEditPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(FourZhuEditPage), findsOneWidget);
  });
}
