import 'package:flutter/material.dart';
import 'full_features_example_screen.dart';

/// Single unified screen entry point for the Adaptive Video Player example.
class ShowcaseScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final String currentLanguageCode;
  final ValueChanged<String> onSelectLanguage;

  const ShowcaseScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.currentLanguageCode,
    required this.onSelectLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return FullFeaturesExampleScreen(
      isDark: isDark,
      onToggleTheme: onToggleTheme,
      currentLanguageCode: currentLanguageCode,
      onSelectLanguage: onSelectLanguage,
    );
  }
}
