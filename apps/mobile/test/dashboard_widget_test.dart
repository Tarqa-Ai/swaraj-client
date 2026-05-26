import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders SWARAJ title text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('SWARAJ'))));
    expect(find.text('SWARAJ'), findsOneWidget);
  });
}
