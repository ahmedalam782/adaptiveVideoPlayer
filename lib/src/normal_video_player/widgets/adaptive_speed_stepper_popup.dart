import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../utils/player_chrome_utils.dart';
import '../utils/video_player_web_safe.dart';

/// Playback speed control for Windows, web, and tablet.
///
/// [asSheet] is the full-width slider. Otherwise the card uses [maxWidth].
class ResponsiveSpeedPanel extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  /// Full-width bottom sheet used on phone and tablet surfaces.
  final bool asSheet;

  /// Caps the card width on smaller desktop and web players.
  final double? maxWidth;

  static const List<double> defaultSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5];

  const ResponsiveSpeedPanel({
    super.key,
    required this.controller,
    this.styling,
    this.messages,
    this.onClose,
    this.asSheet = false,
    this.maxWidth,
  });

  String _formatSpeedLabel(double speed, BuildContext context) {
    final normalWord = (messages?.resolveTextDirection(context) == TextDirection.rtl)
        ? 'عادية'
        : 'Normal';
    if (speed == 1.0) {
      return '1x ($normalWord)';
    }
    return '${speed}x';
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;

    if (asSheet) {
      return Directionality(
        textDirection: textDirection,
        child: ResponsiveSpeedSheet(
          controller: controller,
          onClose: onClose,
          formatLabel: (speed) => speed == 1.0
              ? '1x'
              : '${speed}x',
          normalLabel: isRtl ? 'عادية' : 'Normal',
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: maxWidth ?? 420,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: styling?.settingsBackgroundColor ?? const Color(0xE61F1F1F),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, _) {
              final currentSpeed = value.playbackSpeed;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    messages?.playbackSpeedText ?? (isRtl ? 'سرعة العرض' : 'Playback Speed'),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Horizontal Stepper Bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stepCount = defaultSpeeds.length;

                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Base horizontal connecting track line
                          Container(
                            height: 2.5,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            color: Colors.white.withValues(alpha: 0.28),
                          ),

                          // Discrete step nodes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(stepCount, (index) {
                              final speed = defaultSpeeds[index];
                              final isSelected =
                                  (currentSpeed - speed).abs() < 0.05;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  controller.setPlaybackSpeed(speed);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: isSelected
                                      ? Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Labels Row
                  Row(
                    children: List.generate(defaultSpeeds.length, (index) {
                      final speed = defaultSpeeds[index];
                      final isSelected = (currentSpeed - speed).abs() < 0.05;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            controller.setPlaybackSpeed(speed);
                          },
                          child: Text(
                            _formatSpeedLabel(speed, context),
                            textAlign: index == 0
                                ? TextAlign.start
                                : (index == defaultSpeeds.length - 1
                                    ? TextAlign.end
                                    : TextAlign.center),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.65),
                              fontSize: isSelected ? 13 : 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Previous name. Prefer [ResponsiveSpeedPanel].
typedef AdaptiveSpeedStepperPopup = ResponsiveSpeedPanel;

/// Full-width speed stepper used on a phone or tablet.
class ResponsiveSpeedSheet extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? onClose;
  final String Function(double speed) formatLabel;
  final String normalLabel;

  const ResponsiveSpeedSheet({
    super.key,
    required this.controller,
    required this.formatLabel,
    required this.normalLabel,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF22A2A2A),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final speeds = ResponsiveSpeedPanel.defaultSpeeds;
              final current = PlayerChromeUtils.nearestSpeed(
                value.playbackSpeed,
                speeds,
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ResponsiveSpeedStepper(
                      speeds: speeds,
                      current: current,
                      formatLabel: formatLabel,
                      normalLabel: normalLabel,
                      onSelected: controller.setPlaybackSpeed,
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Discrete speed stops. Each number sits under its own step.
class ResponsiveSpeedStepper extends StatelessWidget {
  final List<double> speeds;
  final double current;
  final String Function(double speed) formatLabel;
  final String normalLabel;
  final ValueChanged<double> onSelected;

  const ResponsiveSpeedStepper({
    super.key,
    required this.speeds,
    required this.current,
    required this.formatLabel,
    required this.normalLabel,
    required this.onSelected,
  });

  void _selectAt(List<double> ordered, double dx, double width) {
    final index = PlayerChromeUtils.speedIndexAt(
      dx: dx,
      width: width,
      count: ordered.length,
      rtl: false,
    );
    onSelected(ordered[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final ordered = isRtl ? speeds.reversed.toList() : speeds;
    final currentIndex = ordered.indexWhere(
      (speed) => (speed - current).abs() < 0.05,
    );
    final slowIndex = ordered.indexWhere(
      (speed) => (speed - speeds.first).abs() < 0.05,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _selectAt(ordered, details.localPosition.dx, width),
          onHorizontalDragStart: (details) =>
              _selectAt(ordered, details.localPosition.dx, width),
          onHorizontalDragUpdate: (details) =>
              _selectAt(ordered, details.localPosition.dx, width),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 28,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ResponsiveSpeedTrack(
                        count: ordered.length,
                        fromIndex: slowIndex < 0 ? 0 : slowIndex,
                        toIndex: currentIndex < 0 ? 0 : currentIndex,
                      ),
                      Row(
                        children: [
                          for (final speed in ordered)
                            Expanded(
                              child: Center(
                                child: ResponsiveSpeedStepDot(
                                  key: ValueKey('speed-stop-$speed'),
                                  selected: (speed - current).abs() < 0.05,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final speed in ordered)
                      Expanded(
                        child: ResponsiveSpeedStop(
                          label: formatLabel(speed),
                          caption: speed == 1.0 ? normalLabel : null,
                          selected: (current - speed).abs() < 0.05,
                          onTap: () => onSelected(speed),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Line that runs through the speed steps, filled up to the selected stop.
class ResponsiveSpeedTrack extends StatelessWidget {
  final int count;
  final int fromIndex;
  final int toIndex;

  const ResponsiveSpeedTrack({
    super.key,
    required this.count,
    required this.fromIndex,
    required this.toIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    final start = fromIndex < toIndex ? fromIndex : toIndex;
    final end = fromIndex < toIndex ? toIndex : fromIndex;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: i == 0
                        ? Colors.transparent
                        : (i > start && i <= end
                            ? Colors.white
                            : Colors.white24),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: i == count - 1
                        ? Colors.transparent
                        : (i >= start && i < end
                            ? Colors.white
                            : Colors.white24),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The marker drawn on a speed number.
class ResponsiveSpeedStepDot extends StatelessWidget {
  final bool selected;

  const ResponsiveSpeedStepDot({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: selected ? 18 : 8,
      height: selected ? 18 : 8,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white70,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// One speed label, centered on its slider stop.
class ResponsiveSpeedStop extends StatelessWidget {
  final String label;
  final String? caption;
  final bool selected;
  final VoidCallback onTap;

  const ResponsiveSpeedStop({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          if (caption != null)
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
