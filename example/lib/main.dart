import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:adaptive_video_player/adaptive_video_player.dart';

import 'screens/showcase_screen.dart';
import 'widgets/language_picker_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  AdaptiveVideoPlayerPlatform.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales:
          supportedLanguages.map((lang) => Locale(lang.code)).toList(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF6366F1); // Indigo
    final currentLang =
        LanguagePickerSheet.getLanguage(context.locale.languageCode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Video Player Studio',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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
          textDirection:
              currentLang.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
      home: ShowcaseScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        currentLanguageCode: context.locale.languageCode,
        onSelectLanguage: (code) => context.setLocale(Locale(code)),
      ),
    );
  }
}
