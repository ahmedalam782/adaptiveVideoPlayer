/// Result object returned when exiting fullscreen mode (SRP)
class FullScreenResult {
  final Duration position;
  final bool wasPlaying;
  final bool isMuted;
  final bool autoPlay;
  final bool loop;
  final bool forceHD;
  final bool enableCaption;
  final bool videoEnded;

  FullScreenResult({
    required this.position,
    required this.wasPlaying,
    required this.isMuted,
    required this.autoPlay,
    required this.loop,
    required this.forceHD,
    required this.enableCaption,
    this.videoEnded = false,
  });
}
