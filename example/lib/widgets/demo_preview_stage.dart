import 'package:flutter/material.dart';

/// Which player design the example is staging for a tester.
enum DemoPreviewMode { phone, tablet, desktop }

/// Sizes that match the player's phone, tablet, and desktop rules.
class DemoPreviewSpec {
  final DemoPreviewMode mode;
  final Size window;
  final Size player;
  final double outerWidth;
  final double outerHeight;
  final EdgeInsets bezel;
  final double titleBarHeight;
  final double outerRadius;
  final double screenRadius;
  final Color accent;
  final String title;
  final String detail;

  const DemoPreviewSpec({
    required this.mode,
    required this.window,
    required this.player,
    required this.outerWidth,
    required this.outerHeight,
    required this.bezel,
    required this.titleBarHeight,
    required this.outerRadius,
    required this.screenRadius,
    required this.accent,
    required this.title,
    required this.detail,
  });

  static DemoPreviewSpec of(DemoPreviewMode mode) {
    return switch (mode) {
      DemoPreviewMode.phone => const DemoPreviewSpec(
          mode: DemoPreviewMode.phone,
          window: Size(844, 390),
          player: Size(800, 450),
          outerWidth: 836,
          outerHeight: 490,
          bezel: EdgeInsets.fromLTRB(18, 18, 18, 22),
          titleBarHeight: 0,
          outerRadius: 36,
          screenRadius: 18,
          accent: Color(0xFFE50914),
          title: 'Phone · 844×390',
          detail: 'Lock, brightness, and labeled actions',
        ),
      DemoPreviewMode.tablet => const DemoPreviewSpec(
          mode: DemoPreviewMode.tablet,
          window: Size(1180, 820),
          player: Size(1024, 576),
          outerWidth: 1048,
          outerHeight: 632,
          bezel: EdgeInsets.all(12),
          titleBarHeight: 32,
          outerRadius: 22,
          screenRadius: 10,
          accent: Color(0xFF818CF8),
          title: 'Tablet',
          detail: 'Window chrome with panels that fit',
        ),
      DemoPreviewMode.desktop => const DemoPreviewSpec(
          mode: DemoPreviewMode.desktop,
          window: Size(1600, 1000),
          player: Size(1280, 720),
          outerWidth: 1300,
          outerHeight: 772,
          bezel: EdgeInsets.fromLTRB(10, 8, 10, 10),
          titleBarHeight: 34,
          outerRadius: 16,
          screenRadius: 8,
          accent: Color(0xFF38BDF8),
          title: 'Desktop & web',
          detail: 'Window chrome with floating panels',
        ),
    };
  }

  /// Picks the stage that matches the real window before the tester overrides it.
  static DemoPreviewMode forWindow(Size window) {
    if (window.shortestSide <= 0) return DemoPreviewMode.desktop;
    final shortest = window.shortestSide;
    final longest = window.longestSide;
    if (shortest < 600) return DemoPreviewMode.phone;
    if (shortest <= 1100 && longest <= 1400) return DemoPreviewMode.tablet;
    if (longest < 1200) return DemoPreviewMode.tablet;
    return DemoPreviewMode.desktop;
  }
}

class DemoModePicker extends StatelessWidget {
  final DemoPreviewMode mode;
  final ValueChanged<DemoPreviewMode> onChanged;

  const DemoModePicker({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final item in DemoPreviewMode.values) ...[
          if (item != DemoPreviewMode.phone) const SizedBox(width: 8),
          Expanded(
            child: DemoModeCard(
              spec: DemoPreviewSpec.of(item),
              selected: item == mode,
              onTap: () => onChanged(item),
            ),
          ),
        ],
      ],
    );
  }
}

class DemoModeCard extends StatelessWidget {
  final DemoPreviewSpec spec;
  final bool selected;
  final VoidCallback onTap;

  const DemoModeCard({
    super.key,
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? spec.accent.withValues(alpha: isDark ? 0.18 : 0.12)
        : (isDark ? const Color(0xFF121826) : Colors.white);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? spec.accent
                  : (isDark ? const Color(0xFF2A3348) : const Color(0xFFE2E8F0)),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, color: spec.accent, size: 18),
                const SizedBox(height: 8),
                Text(
                  spec.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  spec.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (spec.mode) {
      DemoPreviewMode.phone => Icons.smartphone_rounded,
      DemoPreviewMode.tablet => Icons.tablet_mac_rounded,
      DemoPreviewMode.desktop => Icons.desktop_windows_rounded,
    };
  }
}

/// Scales a device frame so the tester can open any design on this screen.
class DemoPreviewStage extends StatelessWidget {
  final DemoPreviewMode mode;
  final Widget child;

  const DemoPreviewStage({
    super.key,
    required this.mode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final spec = DemoPreviewSpec.of(mode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            spec.accent.withValues(alpha: isDark ? 0.16 : 0.10),
            isDark ? const Color(0xFF0C1018) : const Color(0xFFF8FAFC),
          ],
        ),
        border: Border.all(
          color: spec.accent.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          children: [
            DemoStageCaption(spec: spec),
            const SizedBox(height: 10),
            Expanded(
              child: spec.mode == DemoPreviewMode.phone
                  ? DemoPhoneFrame(
                      child: DemoSurfaceScope(spec: spec, child: child),
                    )
                  : FittedBox(
                      fit: BoxFit.contain,
                      child: DemoDeviceFrame(
                        spec: spec,
                        child: DemoSurfaceScope(spec: spec, child: child),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoStageCaption extends StatelessWidget {
  final DemoPreviewSpec spec;

  const DemoStageCaption({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: spec.accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Testing the ${spec.title.toLowerCase()} design',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Landscape phone that fills the stage so the mobile controls stay readable.
class DemoPhoneFrame extends StatelessWidget {
  final Widget child;

  const DemoPhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF07090E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE50914).withValues(alpha: 0.55),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38E50914),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(color: Colors.black, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoDeviceFrame extends StatelessWidget {
  final DemoPreviewSpec spec;
  final Widget child;

  const DemoDeviceFrame({
    super.key,
    required this.spec,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: spec.outerWidth,
      height: spec.outerHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: BorderRadius.circular(spec.outerRadius),
          border: Border.all(color: spec.accent.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: spec.accent.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: spec.bezel,
          child: Column(
            children: [
              if (spec.titleBarHeight > 0)
                SizedBox(
                  height: spec.titleBarHeight,
                  child: DemoFrameTitleBar(spec: spec),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(spec.screenRadius),
                child: ColoredBox(color: Colors.black, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoFrameTitleBar extends StatelessWidget {
  final DemoPreviewSpec spec;

  const DemoFrameTitleBar({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DemoWindowDots(),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            spec.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class DemoWindowDots extends StatelessWidget {
  const DemoWindowDots({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(Color(0xFFFF5F57)),
        SizedBox(width: 5),
        _Dot(Color(0xFFFEBC2E)),
        SizedBox(width: 5),
        _Dot(Color(0xFF28C840)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Gives the player the window size of the selected design.
class DemoSurfaceScope extends StatelessWidget {
  final DemoPreviewSpec spec;
  final Widget child;

  const DemoSurfaceScope({
    super.key,
    required this.spec,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context).copyWith(
      size: spec.window,
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    );
    if (spec.mode == DemoPreviewMode.phone) {
      return MediaQuery(data: data, child: SizedBox.expand(child: child));
    }
    return MediaQuery(
      data: data,
      child: SizedBox.fromSize(size: spec.player, child: child),
    );
  }
}

class DemoTryStep {
  final IconData icon;
  final String title;
  final String detail;

  const DemoTryStep({
    required this.icon,
    required this.title,
    required this.detail,
  });

  static List<DemoTryStep> forMode(DemoPreviewMode mode) {
    return switch (mode) {
      DemoPreviewMode.phone => const [
          DemoTryStep(
            icon: Icons.touch_app_rounded,
            title: 'Show controls',
            detail: 'Tap the picture',
          ),
          DemoTryStep(
            icon: Icons.lock_rounded,
            title: 'Lock',
            detail: 'Then tap the badge to unlock',
          ),
          DemoTryStep(
            icon: Icons.brightness_6_rounded,
            title: 'Brightness',
            detail: 'Drag the slider on the right',
          ),
          DemoTryStep(
            icon: Icons.subtitles_rounded,
            title: 'Audio & subtitles',
            detail: 'Two columns fill the screen',
          ),
          DemoTryStep(
            icon: Icons.view_carousel_rounded,
            title: 'Episodes',
            detail: 'Switch season on Big Buck Bunny',
          ),
          DemoTryStep(
            icon: Icons.speed_rounded,
            title: 'Speed',
            detail: 'Slider from 0.5x to 1.5x',
          ),
        ],
      DemoPreviewMode.tablet => const [
          DemoTryStep(
            icon: Icons.touch_app_rounded,
            title: 'Show controls',
            detail: 'Tap the picture',
          ),
          DemoTryStep(
            icon: Icons.swap_horiz_rounded,
            title: 'Scroll actions',
            detail: 'The bar keeps every icon',
          ),
          DemoTryStep(
            icon: Icons.subtitles_rounded,
            title: 'Audio',
            detail: 'The panel fills the window',
          ),
          DemoTryStep(
            icon: Icons.view_carousel_rounded,
            title: 'Episodes',
            detail: 'Horizontal rail inside the window',
          ),
          DemoTryStep(
            icon: Icons.speed_rounded,
            title: 'Speed',
            detail: 'Opens as a bottom sheet',
          ),
        ],
      DemoPreviewMode.desktop => const [
          DemoTryStep(
            icon: Icons.touch_app_rounded,
            title: 'Show controls',
            detail: 'Tap the picture',
          ),
          DemoTryStep(
            icon: Icons.subtitles_rounded,
            title: 'Audio',
            detail: 'Opens as a floating card',
          ),
          DemoTryStep(
            icon: Icons.video_library_rounded,
            title: 'Episodes',
            detail: 'Floating list on Big Buck Bunny',
          ),
          DemoTryStep(
            icon: Icons.speed_rounded,
            title: 'Speed',
            detail: 'Floating card, clamped to the player',
          ),
          DemoTryStep(
            icon: Icons.settings_rounded,
            title: 'Settings',
            detail: 'Drag the card by its handle',
          ),
        ],
    };
  }
}

class DemoTryRail extends StatelessWidget {
  final DemoPreviewMode mode;

  const DemoTryRail({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final steps = DemoTryStep.forMode(mode);
    final accent = DemoPreviewSpec.of(mode).accent;
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: steps.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return DemoTryCard(
            index: index + 1,
            step: steps[index],
            accent: accent,
          );
        },
      ),
    );
  }
}

class DemoTryCard extends StatelessWidget {
  final int index;
  final DemoTryStep step;
  final Color accent;

  const DemoTryCard({
    super.key,
    required this.index,
    required this.step,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 196,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121826) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3348) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        step.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
