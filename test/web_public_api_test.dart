@TestOn('browser')
library;

import 'package:adaptive_video_player/adaptive_video_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('public native services safely fall back in a browser', () async {
    NativePipService.initialize();
    expect(await NativePipService.isSupported(), isFalse);
    expect(await NativePipService.enterPip(), isFalse);
    await NativePipService.setPipEnabled(true);
    await NativePipService.updatePlaybackState(isPlaying: true);
    await NativePipService.exitPip();
    await NativePipService.closePip();
    expect(NativePipService.isInPip.value, isFalse);

    final server = YouTubeLocalServerService();
    expect(await server.start(), isNull);
    expect(server.serverUrl, isNull);
    expect(server.isRunning, isFalse);
    server.stop();

    expect(
      await createCachedVideoController(Uri.parse('https://example.com/a.mp4')),
      isNull,
    );
    await clearVideoDiskCache();
  });
}
