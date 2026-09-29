import 'package:flutter/widgets.dart';

/// Segregated interface for handling fullscreen transitions (SRP & DIP)
abstract class IFullscreenService {
  /// Whether player is currently in fullscreen mode
  bool get isFullscreen;

  /// Enter fullscreen mode
  Future<void> enterFullscreen({BuildContext? context});

  /// Exit fullscreen mode
  Future<void> exitFullscreen({BuildContext? context});

  /// Toggle fullscreen mode
  Future<void> toggleFullscreen({BuildContext? context});

  /// Dispose any resources/listeners
  void dispose();
}
