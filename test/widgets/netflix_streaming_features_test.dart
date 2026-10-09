import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/audio_track.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/subtitle_track.dart';
import 'package:adaptive_video_player/src/normal_video_player/models/video_episode.dart';
import 'package:adaptive_video_player/src/normal_video_player/utils/video_player_web_safe.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_audio_subtitles_popup.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_bottom_bar.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_episodes_drawer.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_fullscreen_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_inline_bottom_bar.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_next_episode_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_play_pause_button.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_speed_stepper_popup.dart';
import 'package:adaptive_video_player/src/normal_video_player/widgets/adaptive_top_bar.dart';
import 'package:adaptive_video_player/src/youtube_player/models/youtube_player_config.dart';

void main() {
  group('Netflix-Style Streaming Player Features Tests', () {
    late VideoPlayerController controller;

    setUp(() {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://media.w3.org/2010/05/bunny/trailer.mp4',
        ),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('AdaptiveSpeedStepperPopup renders and updates playback speed',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: Center(
                child: AdaptiveSpeedStepperPopup(
                  controller: controller,
                  messages: const PlayerTextConfig(
                    playbackSpeedText: 'سرعة العرض',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('سرعة العرض'), findsOneWidget);
      expect(find.text('0.5x'), findsOneWidget);
      expect(find.text('1.5x'), findsOneWidget);

      // Tap 1.5x
      await tester.tap(find.text('1.5x'));
      await tester.pump();

      expect(controller.value.playbackSpeed, equals(1.5));
    });

    testWidgets(
        'AdaptiveAudioSubtitlesPopup renders dual columns and handles selection',
        (tester) async {
      AudioTrack? selectedAudio;
      SubtitleTrack? selectedSub;

      final audioTracks = [
        const AudioTrack(
          id: 'en_orig',
          label: 'الإنجليزية [أصلي]',
          isOriginal: true,
          isDefault: true,
        ),
        const AudioTrack(
          id: 'ar_audio',
          label: 'العربية (صوت)',
        ),
      ];

      final subtitleTracks = [
        const SubtitleTrack(
          id: 'sub_ar',
          title: 'العربية (ترجمة)',
        ),
        const SubtitleTrack(
          id: 'sub_en',
          title: 'English (CC)',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveAudioSubtitlesPopup(
              audioTracks: audioTracks,
              currentAudioTrack: audioTracks.first,
              onAudioTrackSelected: (t) => selectedAudio = t,
              subtitles: subtitleTracks,
              currentSubtitleTrack: subtitleTracks.first,
              onSubtitleSelected: (s) => selectedSub = s,
              messages: const PlayerTextConfig(
                audioText: 'الصوت',
                subtitlesText: 'الترجمة',
                offText: 'إيقاف التشغيل',
              ),
            ),
          ),
        ),
      );

      expect(find.text('الصوت'), findsOneWidget);
      expect(find.text('الترجمة'), findsOneWidget);
      expect(find.text('الإنجليزية [أصلي]'), findsOneWidget);
      expect(find.text('إيقاف التشغيل'), findsOneWidget);

      // Tap Arabic audio track
      await tester.tap(find.text('العربية (صوت)'));
      await tester.pump();
      expect(selectedAudio?.id, equals('ar_audio'));

      // Tap English subtitle track
      await tester.tap(find.text('English (CC)'));
      await tester.pump();
      expect(selectedSub?.id, equals('sub_en'));
    });

    testWidgets(
        'AdaptiveEpisodesDrawer renders episode list, progress bars, and active badge',
        (tester) async {
      VideoEpisode? clickedEpisode;

      final episodes = [
        const VideoEpisode(
          id: 'ep1',
          number: 1,
          title: 'ذرة من الحقيقة',
          watchedProgress: 1.0,
        ),
        const VideoEpisode(
          id: 'ep6',
          number: 6,
          title: 'صديقتي العزيزة...',
          description: 'يفقد جيرالت صديقة عزيزة...',
          watchedProgress: 0.65,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveEpisodesDrawer(
              episodes: episodes,
              currentEpisode: episodes[1],
              onEpisodeSelected: (ep) => clickedEpisode = ep,
              messages: const PlayerTextConfig(
                episodesText: 'الحلقات',
                nowPlayingText: 'يعرض الآن',
              ),
            ),
          ),
        ),
      );

      expect(find.text('الحلقات'), findsOneWidget);
      expect(find.text('ذرة من الحقيقة'), findsOneWidget);
      expect(find.text('صديقتي العزيزة...'), findsOneWidget);
      expect(find.text('يعرض الآن'), findsOneWidget);
      expect(find.text('يفقد جيرالت صديقة عزيزة...'), findsOneWidget);

      // Tap episode 1
      await tester.tap(find.text('ذرة من الحقيقة'));
      await tester.pump();

      expect(clickedEpisode?.id, equals('ep1'));
    });

    testWidgets('AdaptiveNextEpisodeButton renders and triggers onNextEpisode',
        (tester) async {
      bool nextTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNextEpisodeButton(
              onNextEpisode: () => nextTapped = true,
              messages: const PlayerTextConfig(
                nextEpisodeText: 'الحلقة التالية',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pump();

      expect(nextTapped, isTrue);
    });

    testWidgets('AdaptiveBottomBar displays centered title when provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 100,
              child: AdaptiveBottomBar(
                controller: controller,
                isFullScreen: false,
                title: 'The Witcher حلقة 6 صديقتي العزيزة...',
                visibility: const PlayerVisibilityConfig(
                  showCenteredTitle: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('The Witcher حلقة 6 صديقتي العزيزة...'),
        findsOneWidget,
      );
    });

    test('PlayerTextConfig dynamically handles Netflix streaming keys in all modes', () {
      // 1. fromMap and toMap
      final customMap = {
        'episodes': 'Lista de Episodios',
        'next_episode': 'Próximo',
        'audio': 'Áudio',
        'now_playing': 'Tocando agora',
        'audio_description': 'Descrição de Áudio',
        'audio_and_subtitles': 'Áudio e Legendas',
      };
      final textConfig = PlayerTextConfig.fromMap(customMap);
      expect(textConfig.episodesText, equals('Lista de Episodios'));
      expect(textConfig.nextEpisodeText, equals('Próximo'));
      expect(textConfig.audioText, equals('Áudio'));
      expect(textConfig.nowPlayingText, equals('Tocando agora'));
      expect(textConfig.audioDescriptionText, equals('Descrição de Áudio'));
      expect(textConfig.audioAndSubtitlesText, equals('Áudio e Legendas'));

      final exportedMap = textConfig.toMap();
      expect(exportedMap['episodes'], equals('Lista de Episodios'));
      expect(exportedMap['next_episode'], equals('Próximo'));
      expect(exportedMap['audio'], equals('Áudio'));

      // 2. Dynamic translator
      final dynamicConfig = PlayerTextConfig.dynamic(
        translate: (key, fallback) => 'DYN_$key',
      );
      expect(dynamicConfig.episodesText, equals('DYN_episodes'));
      expect(dynamicConfig.nextEpisodeText, equals('DYN_next_episode'));
      expect(dynamicConfig.audioText, equals('DYN_audio'));
      expect(dynamicConfig.nowPlayingText, equals('DYN_now_playing'));
      expect(dynamicConfig.audioDescriptionText, equals('DYN_audio_description'));
      expect(dynamicConfig.audioAndSubtitlesText, equals('DYN_audio_and_subtitles'));

      // 3. Convenience arabic constructor
      const arabicConfig = PlayerTextConfig.arabic();
      expect(arabicConfig.episodesText, equals('الحلقات'));
      expect(arabicConfig.nextEpisodeText, equals('الحلقة التالية'));
      expect(arabicConfig.audioText, equals('الصوت'));
      expect(arabicConfig.nowPlayingText, equals('يعرض الآن'));
      expect(arabicConfig.audioDescriptionText, equals('الوصف الصوتي'));
      expect(arabicConfig.audioAndSubtitlesText, equals('الصوت والترجمة'));

      // 4. Default English keys
      const defConfig = PlayerTextConfig();
      expect(defConfig.episodesText, equals('Episodes'));
      expect(defConfig.nextEpisodeText, equals('Next Episode'));
      expect(defConfig.audioText, equals('Audio'));
      expect(defConfig.nowPlayingText, equals('Now Playing'));
      expect(defConfig.audioDescriptionText, equals('Audio Description'));
      expect(defConfig.audioAndSubtitlesText, equals('Audio & Subtitles'));
    });

    testWidgets(
        'AdaptiveInlineBottomBar renders streaming buttons and triggers callbacks',
        (tester) async {
      bool nextEpisodeTapped = false;
      bool episodesTapped = false;
      bool audioSubsTapped = false;
      bool speedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 100,
              child: AdaptiveInlineBottomBar(
                controller: controller,
                isFullScreen: false,
                isLive: false,
                title: 'Inline Title Episode 6',
                episodes: const [
                  VideoEpisode(id: '1', number: 1, title: 'Ep 1'),
                  VideoEpisode(id: '2', number: 2, title: 'Ep 2'),
                ],
                onNextEpisode: () => nextEpisodeTapped = true,
                onEpisodesPressed: () => episodesTapped = true,
                audioTracks: const [
                  AudioTrack(id: 'en', label: 'English'),
                ],
                onAudioSubtitlesPressed: () => audioSubsTapped = true,
                onSpeedPressed: () => speedTapped = true,
              ),
            ),
          ),
        ),
      );

      // Verify buttons are rendered
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.subtitles_outlined), findsOneWidget);
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.text('Inline Title Episode 6'), findsOneWidget);

      // Tap buttons
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      expect(nextEpisodeTapped, isTrue);

      await tester.tap(find.byIcon(Icons.video_library_outlined));
      expect(episodesTapped, isTrue);

      await tester.tap(find.byIcon(Icons.subtitles_outlined));
      expect(audioSubsTapped, isTrue);

      await tester.tap(find.byIcon(Icons.speed_rounded));
      expect(speedTapped, isTrue);
    });

    testWidgets('AdaptiveInlineBottomBar renders at 650px without overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 650,
                height: 60,
                child: AdaptiveInlineBottomBar(
                  controller: controller,
                  isFullScreen: false,
                  isLive: false,
                  showSkipButtons: true,
                  title: 'Overflow Test Video Title',
                  visibility: const PlayerVisibilityConfig(
                    showStopButton: true,
                    showNextEpisodeButton: true,
                    showSkipButtons: true,
                    showTimeDisplay: true,
                    showProgressBar: true,
                    showVolumeButton: true,
                    showCenteredTitle: true,
                    showLoopSetting: true,
                    showCaptionsSetting: true,
                    showSpeedButton: true,
                    showAudioSubtitlesButton: true,
                    showEpisodesButton: true,
                    showSettingsButton: true,
                    showMiniPlayerButton: true,
                    showFullscreenButton: true,
                  ),
                  onNextEpisode: () {},
                  onEpisodesPressed: () {},
                  onAudioSubtitlesPressed: () {},
                  onSpeedPressed: () {},
                  onMiniPlayerPressed: () {},
                  onEnterFullscreen: () {},
                  onSettingsPressed: () {},
                  episodes: const [VideoEpisode(id: '1', number: 1, title: 'Ep 1')],
                  audioTracks: const [AudioTrack(id: 'en', label: 'English')],
                  subtitles: const [SubtitleTrack(id: 'en', title: 'English')],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdaptiveInlineBottomBar renders at 450px without overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 450,
                height: 60,
                child: AdaptiveInlineBottomBar(
                  controller: controller,
                  isFullScreen: false,
                  isLive: false,
                  showSkipButtons: true,
                  title: 'Overflow Test Video Title',
                  visibility: const PlayerVisibilityConfig(
                    showStopButton: true,
                    showNextEpisodeButton: true,
                    showSkipButtons: true,
                    showTimeDisplay: true,
                    showProgressBar: true,
                    showVolumeButton: true,
                    showCenteredTitle: true,
                    showLoopSetting: true,
                    showCaptionsSetting: true,
                    showSpeedButton: true,
                    showAudioSubtitlesButton: true,
                    showEpisodesButton: true,
                    showSettingsButton: true,
                    showMiniPlayerButton: true,
                    showFullscreenButton: true,
                  ),
                  onNextEpisode: () {},
                  onEpisodesPressed: () {},
                  onAudioSubtitlesPressed: () {},
                  onSpeedPressed: () {},
                  onMiniPlayerPressed: () {},
                  onEnterFullscreen: () {},
                  onSettingsPressed: () {},
                  episodes: const [VideoEpisode(id: '1', number: 1, title: 'Ep 1')],
                  audioTracks: const [AudioTrack(id: 'en', label: 'English')],
                  subtitles: const [SubtitleTrack(id: 'en', title: 'English')],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdaptiveInlineBottomBar renders at 360px without overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 60,
                child: AdaptiveInlineBottomBar(
                  controller: controller,
                  isFullScreen: false,
                  isLive: false,
                  showSkipButtons: true,
                  title: 'Overflow Test Video Title',
                  visibility: const PlayerVisibilityConfig(
                    showStopButton: true,
                    showNextEpisodeButton: true,
                    showSkipButtons: true,
                    showTimeDisplay: true,
                    showProgressBar: true,
                    showVolumeButton: true,
                    showCenteredTitle: true,
                    showLoopSetting: true,
                    showCaptionsSetting: true,
                    showSpeedButton: true,
                    showAudioSubtitlesButton: true,
                    showEpisodesButton: true,
                    showSettingsButton: true,
                    showMiniPlayerButton: true,
                    showFullscreenButton: true,
                  ),
                  onNextEpisode: () {},
                  onEpisodesPressed: () {},
                  onAudioSubtitlesPressed: () {},
                  onSpeedPressed: () {},
                  onMiniPlayerPressed: () {},
                  onEnterFullscreen: () {},
                  onSettingsPressed: () {},
                  episodes: const [VideoEpisode(id: '1', number: 1, title: 'Ep 1')],
                  audioTracks: const [AudioTrack(id: 'en', label: 'English')],
                  subtitles: const [SubtitleTrack(id: 'en', title: 'English')],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'AdaptiveBottomBar renders mobile-optimized layout on 400px without squishing icons or middle title',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: AdaptiveBottomBar(
                  controller: controller,
                  isFullScreen: false,
                  title: 'The Witcher: Episode 6',
                  visibility: const PlayerVisibilityConfig(
                    showCenteredTitle: true,
                    showVolumeButton: true,
                    showFullscreenButton: true,
                    showSettingsButton: true,
                    showTimeDisplay: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // On 400px width, centered title should NOT be squeezed between icons
      expect(find.text('The Witcher: Episode 6'), findsNothing);
      // Play and Fullscreen buttons are crisp and present
      expect(find.byType(AdaptivePlayPauseButton), findsOneWidget);
      expect(find.byType(AdaptiveFullscreenButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdaptiveTopBar renders title and subtitle properly on top bar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 50,
              child: AdaptiveTopBar(
                isFullScreen: false,
                title: 'The Witcher',
                subtitle: 'Episode 6: Dear Friend',
              ),
            ),
          ),
        ),
      );

      expect(find.text('The Witcher'), findsOneWidget);
      expect(find.text('Episode 6: Dear Friend'), findsOneWidget);
    });
  });
}

