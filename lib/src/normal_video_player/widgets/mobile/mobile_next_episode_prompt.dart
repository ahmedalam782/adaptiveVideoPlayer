import 'package:flutter/material.dart';

/// Phone end-of-episode actions: next episode and watch credits.
class MobileNextEpisodePrompt extends StatelessWidget {
  final String nextLabel;
  final String creditsLabel;
  final VoidCallback onNext;
  final VoidCallback onWatchCredits;

  const MobileNextEpisodePrompt({
    super.key,
    required this.nextLabel,
    required this.creditsLabel,
    required this.onNext,
    required this.onWatchCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: onNext,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              nextLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A2A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: onWatchCredits,
            child: Text(creditsLabel),
          ),
        ],
      ),
    );
  }
}
