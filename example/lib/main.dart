import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adaptive_video_player/adaptive_video_player.dart';

import 'screens/showcase_screen.dart';

void main() {
  AdaptiveVideoPlayerPlatform.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
    });
  }

  bool get _isRtl => _locale.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF6366F1); // Indigo

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Video Player Studio',
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.light,
          surface: Colors.white,
          surfaceContainerHigh: const Color(0xFFEDF2F7),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.dark,
          surface: const Color(0xFF111726),
          surfaceContainerHigh: const Color(0xFF182032),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
      home: ShowcaseScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        isRtl: _isRtl,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}
