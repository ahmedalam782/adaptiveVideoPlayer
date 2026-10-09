/// Helper utility to detect non-fatal, transient playback interruptions.
library;

/// Returns `true` if [message] describes a benign browser/platform interruption
/// (such as Chrome AbortError when play is followed by pause, or autoplay policies)
/// that should not fail the player or display an error screen to the user.
bool isBenignPlaybackError(String? message) {
  if (message == null || message.isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('interrupted by a call to pause') ||
      lower.contains('play() request was interrupted') ||
      lower.contains('aborterror') ||
      lower.contains('ldlk22') ||
      lower.contains('interrupted by a new load request') ||
      lower.contains('notallowederror') ||
      lower.contains("didn't interact with the document first");
}
