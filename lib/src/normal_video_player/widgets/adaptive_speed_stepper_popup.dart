import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../utils/video_player_web_safe.dart';

/// Horizontal discrete speed stepper popup matching Netflix's 'سرعة العرض' design.
class AdaptiveSpeedStepperPopup extends StatelessWidget {
  final VideoPlayerController controller;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  static const List<double> defaultSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5];

  const AdaptiveSpeedStepperPopup({
    super.key,
    required this.controller,
    this.styling,
    this.messages,
    this.onClose,
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

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 420,
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
