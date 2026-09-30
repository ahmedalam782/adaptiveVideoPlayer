import 'package:flutter/material.dart';
import '../models/youtube_player_config.dart';
import '../cubit/youtube_player_cubit.dart';
import 'player_utils.dart';

/// Helper to show YouTube player settings bottom sheet in a consistent manner.
class YouTubeSettingsHelper {
  const YouTubeSettingsHelper._();

  static void openSettingsSheet({
    required BuildContext context,
    required YouTubePlayerConfig config,
    required PlayerCubitState state,
    required YoutubePlayerCubit cubit,
    required Future<void> Function() onReloadPlayer,
    required void Function(bool isMuted) onMutedChanged,
  }) {
    PlayerUtils.showSettings(
      context: context,
      config: PlayerSettingsConfig(
        autoPlay: state.autoPlay,
        loop: state.loop,
        forceHD: state.forceHD,
        enableCaption: state.enableCaption,
        isMuted: state.isMuted,
        settingsBackgroundColor: config.style.settingsBackgroundColor,
        settingItemBackgroundColor: config.style.settingItemBackgroundColor,
        iconColor: config.style.iconColor,
        textColor: config.style.textColor,
        switchInactiveThumbColor: config.style.switchInactiveThumbColor,
        switchInactiveTrackColor: config.style.switchInactiveTrackColor,
        playerSettingsText: config.text.playerSettingsText,
        autoPlayText: config.text.autoPlayText,
        loopVideoText: config.text.loopVideoText,
        forceHdQualityText: config.text.forceHdQualityText,
        enableCaptionsText: config.text.enableCaptionsText,
        muteAudioText: config.text.muteAudioText,
        showAutoPlaySetting: config.visibility.showAutoPlaySetting,
        showLoopSetting: config.visibility.showLoopSetting,
        showForceHDSetting: config.visibility.showForceHDSetting,
        showCaptionsSetting: config.visibility.showCaptionsSetting,
        showMuteSetting: config.visibility.showMuteSetting,
        settingsTitleStyle: config.style.settingsTitleStyle,
        settingItemTextStyle: config.style.settingItemTextStyle,
        textDirection: config.text.resolveTextDirection(context),
      ),
      onAutoPlayChanged: (value) async {
        if (state.autoPlay != value) {
          cubit.setAutoPlay(value);
          await onReloadPlayer();
        }
      },
      onLoopChanged: (value) async {
        if (state.loop != value) {
          cubit.setLoop(value);
          await onReloadPlayer();
        }
      },
      onForceHDChanged: (value) async {
        if (state.forceHD != value) {
          cubit.setForceHD(value);
          await onReloadPlayer();
        }
      },
      onEnableCaptionChanged: (value) async {
        if (state.enableCaption != value) {
          cubit.setEnableCaption(value);
          await onReloadPlayer();
        }
      },
      onMutedChanged: onMutedChanged,
    );
  }
}
