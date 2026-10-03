import 'package:flutter_test/flutter_test.dart';

import 'package:music_app/main.dart';

import 'package:music_app/services/audio_handler.dart';
import 'package:music_app/services/storage_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Music App renders home page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.initialize();
    final audioHandler = AudioPlayerHandler();

    await tester.pumpWidget(MusicApp(
      audioHandler: audioHandler,
      storageService: storageService,
    ));
    await tester.pump();
  });
}
