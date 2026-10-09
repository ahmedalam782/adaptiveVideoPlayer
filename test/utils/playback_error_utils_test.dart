import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/utils/playback_error_utils.dart';

void main() {
  group('playback_error_utils Tests', () {
    test('identifies Chrome AbortError and pause interruption as benign', () {
      expect(
        isBenignPlaybackError(
          'The play() request was interrupted by a call to pause(). https://goo.gl/LdLk22',
        ),
        isTrue,
      );

      expect(
        isBenignPlaybackError(
          'AbortError: The play() request was interrupted by a call to pause.',
        ),
        isTrue,
      );

      expect(
        isBenignPlaybackError(
          'The play() request was interrupted by a new load request.',
        ),
        isTrue,
      );

      expect(
        isBenignPlaybackError(
          "NotAllowedError: play() failed because the user didn't interact with the document first.",
        ),
        isTrue,
      );
    });

    test('identifies actual media errors as non-benign', () {
      expect(isBenignPlaybackError('MEDIA_ERR_SRC_NOT_SUPPORTED'), isFalse);
      expect(isBenignPlaybackError('DEMUXER_ERROR_COULD_NOT_OPEN'), isFalse);
      expect(
        isBenignPlaybackError('ExoPlaybackException: Decoder init failed'),
        isFalse,
      );
      expect(isBenignPlaybackError('404 Not Found'), isFalse);
      expect(isBenignPlaybackError(null), isFalse);
      expect(isBenignPlaybackError(''), isFalse);
    });
  });
}
