import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:music_app/main.dart';

void main() {
  testWidgets('Music App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicApp());

    expect(find.text('Music App'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}
