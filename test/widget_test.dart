import 'package:flutter_test/flutter_test.dart';

import 'package:music_app/main.dart';

import 'package:music_app/services/audio_handler.dart';

void main() {
  testWidgets('Music App renders home page', (WidgetTester tester) async {
    final audioHandler = AudioPlayerHandler();
    await tester.pumpWidget(MusicApp(audioHandler: audioHandler));
  });
}
