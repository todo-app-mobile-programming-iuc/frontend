import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flut/main.dart';

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Yetiştir'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
