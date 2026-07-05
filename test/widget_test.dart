import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test ortamı açılır', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('Eczanem')));
    expect(find.text('Eczanem'), findsOneWidget);
  });
}
