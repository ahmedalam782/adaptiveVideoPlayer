import 'package:adaptive_video_player/src/normal_video_player/utils/player_surface_tier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolvePlayerSurfaceTier', () {
    test('phone screens use the mobile chrome', () {
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(390, 844),
          player: const Size(390, 220),
        ),
        PlayerSurfaceTier.phone,
      );
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(844, 390),
          player: const Size(844, 390),
        ),
        PlayerSurfaceTier.phone,
      );
    });

    test('tablet and resized desktop windows use the tablet chrome', () {
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(1180, 820),
          player: const Size(1180, 820),
        ),
        PlayerSurfaceTier.tablet,
      );
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(1366, 1024),
          player: const Size(1366, 1024),
        ),
        PlayerSurfaceTier.tablet,
      );
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(1100, 700),
          player: const Size(1100, 700),
        ),
        PlayerSurfaceTier.tablet,
      );
    });

    test('wide desktop windows keep the desktop chrome', () {
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(1920, 1080),
          player: const Size(1600, 900),
        ),
        PlayerSurfaceTier.desktop,
      );
    });

    testWidgets('fullscreen keeps the phone design on a wide window',
        (tester) async {
      PlayerSurfaceTier? seen;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1920, 1080)),
          child: PlayerSurfaceScope(
            tier: PlayerSurfaceTier.phone,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  seen = playerSurfaceTierOf(context, const Size(1600, 900));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(seen, PlayerSurfaceTier.phone);
    });

    test('a narrow player on a wide window keeps the window design', () {
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(1920, 1080),
          player: const Size(800, 450),
        ),
        PlayerSurfaceTier.tablet,
      );
      expect(
        resolvePlayerSurfaceTier(
          window: const Size(1920, 1080),
          player: const Size(480, 270),
        ),
        PlayerSurfaceTier.tablet,
      );
    });
  });

  group('isDesktopSurface', () {
    testWidgets('returns false on phone screen', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        bool? result;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Builder(
              builder: (context) {
                result = isDesktopSurface(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(result, false);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('returns false on tablet screen', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        bool? result;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1180, 820)),
            child: Builder(
              builder: (context) {
                result = isDesktopSurface(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(result, false);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('returns false on Android even with large screen',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        bool? result;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                result = isDesktopSurface(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(result, false);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('returns false on iOS even with large screen', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        bool? result;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                result = isDesktopSurface(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(result, false);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('returns true on wide desktop window on desktop platform',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        bool? result;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                result = isDesktopSurface(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(result, true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('respects PlayerSurfaceScope', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        bool? phoneResult;
        bool? tabletResult;
        bool? desktopResult;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Column(
              children: [
                PlayerSurfaceScope(
                  tier: PlayerSurfaceTier.phone,
                  child: Builder(
                    builder: (context) {
                      phoneResult = isDesktopSurface(context);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                PlayerSurfaceScope(
                  tier: PlayerSurfaceTier.tablet,
                  child: Builder(
                    builder: (context) {
                      tabletResult = isDesktopSurface(context);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                PlayerSurfaceScope(
                  tier: PlayerSurfaceTier.desktop,
                  child: Builder(
                    builder: (context) {
                      desktopResult = isDesktopSurface(context);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        expect(phoneResult, false);
        expect(tabletResult, false);
        expect(desktopResult, true);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
