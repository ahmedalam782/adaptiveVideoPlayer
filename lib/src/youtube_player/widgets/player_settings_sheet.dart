import 'package:flutter/material.dart';
import 'setting_item.dart';

/// Settings bottom sheet for YouTube player
class PlayerSettingsSheet extends StatefulWidget {
  final bool autoPlay;
  final bool loop;
  final bool forceHD;
  final bool enableCaption;
  final bool isMuted;
  final Future<void> Function(bool) onAutoPlayChanged;
  final Future<void> Function(bool) onLoopChanged;
  final Future<void> Function(bool) onForceHDChanged;
  final Future<void> Function(bool) onEnableCaptionChanged;
  final ValueChanged<bool> onMutedChanged;
  final Color iconColor;
  final Color textColor;
  final Color settingItemBackgroundColor;
  final Color? switchInactiveThumbColor;
  final Color? switchInactiveTrackColor;
  final TextStyle? titleTextStyle;
  final TextStyle? itemTextStyle;
  final String playerSettingsText;
  final String autoPlayText;
  final String loopVideoText;
  final String forceHdQualityText;
  final String enableCaptionsText;
  final String muteAudioText;
  final bool showAutoPlaySetting;
  final bool showLoopSetting;
  final bool showForceHDSetting;
  final bool showCaptionsSetting;
  final bool showMuteSetting;

  const PlayerSettingsSheet({
    super.key,
    required this.autoPlay,
    required this.loop,
    required this.forceHD,
    required this.enableCaption,
    required this.isMuted,
    required this.onAutoPlayChanged,
    required this.onLoopChanged,
    required this.onForceHDChanged,
    required this.onEnableCaptionChanged,
    required this.onMutedChanged,
    required this.iconColor,
    required this.textColor,
    required this.settingItemBackgroundColor,
    required this.switchInactiveThumbColor,
    required this.switchInactiveTrackColor,
    this.titleTextStyle,
    this.itemTextStyle,
    required this.playerSettingsText,
    required this.autoPlayText,
    required this.loopVideoText,
    required this.forceHdQualityText,
    required this.enableCaptionsText,
    required this.muteAudioText,
    required this.showAutoPlaySetting,
    required this.showLoopSetting,
    required this.showForceHDSetting,
    required this.showCaptionsSetting,
    required this.showMuteSetting,
  });

  @override
  State<PlayerSettingsSheet> createState() => _PlayerSettingsSheetState();
}

class _PlayerSettingsSheetState extends State<PlayerSettingsSheet> {
  late bool _autoPlay;
  late bool _loop;
  late bool _forceHD;
  late bool _enableCaption;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _autoPlay = widget.autoPlay;
    _loop = widget.loop;
    _forceHD = widget.forceHD;
    _enableCaption = widget.enableCaption;
    _isMuted = widget.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.settings, color: widget.iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.playerSettingsText,
                    style: widget.titleTextStyle ??
                        TextStyle(
                          color: widget.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: widget.iconColor.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.showAutoPlaySetting) ...[
              SettingItem(
                icon: Icons.play_circle_outline,
                title: widget.autoPlayText,
                value: _autoPlay,
                iconColor: widget.iconColor,
                textColor: widget.textColor,
                backgroundColor: widget.settingItemBackgroundColor,
                switchInactiveThumbColor: widget.switchInactiveThumbColor,
                switchInactiveTrackColor: widget.switchInactiveTrackColor,
                textStyle: widget.itemTextStyle,
                onChanged: (value) {
                  setState(() => _autoPlay = value);
                  widget.onAutoPlayChanged(value);
                },
              ),
              const SizedBox(height: 12),
            ],
            if (widget.showLoopSetting) ...[
              SettingItem(
                icon: Icons.loop,
                title: widget.loopVideoText,
                value: _loop,
                iconColor: widget.iconColor,
                textColor: widget.textColor,
                backgroundColor: widget.settingItemBackgroundColor,
                switchInactiveThumbColor: widget.switchInactiveThumbColor,
                switchInactiveTrackColor: widget.switchInactiveTrackColor,
                textStyle: widget.itemTextStyle,
                onChanged: (value) {
                  setState(() => _loop = value);
                  widget.onLoopChanged(value);
                },
              ),
              const SizedBox(height: 12),
            ],
            if (widget.showForceHDSetting) ...[
              SettingItem(
                icon: Icons.high_quality,
                title: widget.forceHdQualityText,
                value: _forceHD,
                iconColor: widget.iconColor,
                textColor: widget.textColor,
                backgroundColor: widget.settingItemBackgroundColor,
                switchInactiveThumbColor: widget.switchInactiveThumbColor,
                switchInactiveTrackColor: widget.switchInactiveTrackColor,
                textStyle: widget.itemTextStyle,
                onChanged: (value) {
                  setState(() => _forceHD = value);
                  widget.onForceHDChanged(value);
                },
              ),
              const SizedBox(height: 12),
            ],
            if (widget.showCaptionsSetting) ...[
              SettingItem(
                icon: Icons.closed_caption,
                title: widget.enableCaptionsText,
                value: _enableCaption,
                iconColor: widget.iconColor,
                textColor: widget.textColor,
                backgroundColor: widget.settingItemBackgroundColor,
                switchInactiveThumbColor: widget.switchInactiveThumbColor,
                switchInactiveTrackColor: widget.switchInactiveTrackColor,
                textStyle: widget.itemTextStyle,
                onChanged: (value) {
                  setState(() => _enableCaption = value);
                  widget.onEnableCaptionChanged(value);
                },
              ),
              const SizedBox(height: 12),
            ],
            if (widget.showMuteSetting) ...[
              SettingItem(
                icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                title: widget.muteAudioText,
                value: _isMuted,
                iconColor: widget.iconColor,
                textColor: widget.textColor,
                backgroundColor: widget.settingItemBackgroundColor,
                switchInactiveThumbColor: widget.switchInactiveThumbColor,
                switchInactiveTrackColor: widget.switchInactiveTrackColor,
                textStyle: widget.itemTextStyle,
                onChanged: (value) {
                  setState(() => _isMuted = value);
                  widget.onMutedChanged(value);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
