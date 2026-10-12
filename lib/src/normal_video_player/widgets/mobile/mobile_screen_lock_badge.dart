import 'package:flutter/material.dart';

/// Phone lock confirmation. Shown only while the screen is locked.
class MobileScreenLockBadge extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onUnlock;
  final VoidCallback? onDismiss;

  const MobileScreenLockBadge({
    super.key,
    required this.isRtl,
    required this.onUnlock,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Center(
        child: GestureDetector(
          onTap: onUnlock,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                isRtl ? 'الشاشة مقفلة' : 'Screen locked',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isRtl ? 'اضغط لفك القفل' : 'Tap to unlock',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
