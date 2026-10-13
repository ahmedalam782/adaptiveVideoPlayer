import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:adaptive_video_player/adaptive_video_player.dart';

import 'screens/full_features_example_screen.dart';
import 'widgets/language_picker_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  AdaptiveVideoPlayerPlatform.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: supportedLanguages
          .map((lang) => Locale(lang.code))
          .toList(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

/// Keeps the Windows studio the same size at 100%, 125%, and 175% display scale.
///
/// Flutter otherwise grows the whole UI with [MediaQuery.devicePixelRatio].
/// This lays the page out in physical pixels and scales it back, and it also
/// ignores the Windows text-size setting.
class WindowsStableScale extends StatelessWidget {
  final Widget child;

  const WindowsStableScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    print(
      'WindowsStableScale build ${MediaQuery.of(context).size.width} ${MediaQuery.of(context).size.height}',
    );
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
      return child;
    }
    final mq = MediaQuery.of(context);
    final dpr = mq.devicePixelRatio;
    final data = mq.copyWith(
      textScaler: TextScaler.noScaling,
      devicePixelRatio: 1.0,
      size: dpr == 1.0 ? mq.size : mq.size * dpr,
    );
    final page = MediaQuery(data: data, child: child);
    if (dpr == 1.0) return page;
    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: mq.size.width * dpr,
        height: mq.size.height * dpr,
        child: page,
      ),
    );
  }
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
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF6366F1); // Indigo
    final currentLang = LanguagePickerSheet.getLanguage(
      context.locale.languageCode,
    );

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
          textDirection: currentLang.isRtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: WindowsStableScale(child: child ?? const SizedBox.shrink()),
        );
      },
      home: FullFeaturesExampleScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        currentLanguageCode: context.locale.languageCode,
        onSelectLanguage: (code) => context.setLocale(Locale(code)),
      ),
    );
  }
}
