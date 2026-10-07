import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable luxury glassmorphic container with backdrop blur, translucent fill,
/// subtle illuminated borders, and soft ambient shadows (Clean Architecture & SRP).
class AdaptiveGlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final BorderRadius? customBorderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const AdaptiveGlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.borderRadius = 16.0,
    this.customBorderRadius,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadows,
    this.shape = BoxShape.rectangle,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = customBorderRadius ??
        (shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius));
    final effectiveColor = color ?? Colors.black.withValues(alpha: 0.40);
    final effectiveBorderColor =
        borderColor ?? Colors.white.withValues(alpha: 0.18);

    final boxDecoration = BoxDecoration(
      color: effectiveColor,
      shape: shape,
      borderRadius: shape == BoxShape.circle ? null : effectiveRadius,
      border: Border.all(color: effectiveBorderColor, width: borderWidth),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14.0,
              offset: const Offset(0, 4),
            ),
          ],
    );

    Widget content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: boxDecoration,
      child: child,
    );

    if (shape == BoxShape.circle) {
      content = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else if (effectiveRadius != null) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else {
      content = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
