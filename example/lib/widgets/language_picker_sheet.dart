import 'dart:ui';
import 'package:flutter/material.dart';

/// Descriptor for a supported language in the application.
class AppLanguage {
  final String code;
  final String englishName;
  final String nativeName;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    this.isRtl = false,
  });
}

/// All supported languages in the example app, backed by JSON files in assets/translations/
const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'en', englishName: 'English', nativeName: 'English'),
  AppLanguage(code: 'ar', englishName: 'Arabic', nativeName: 'العربية', isRtl: true),
  AppLanguage(code: 'es', englishName: 'Spanish', nativeName: 'Español'),
  AppLanguage(code: 'fr', englishName: 'French', nativeName: 'Français'),
  AppLanguage(code: 'de', englishName: 'German', nativeName: 'Deutsch'),
  AppLanguage(code: 'zh', englishName: 'Chinese (Simplified)', nativeName: '简体中文'),
  AppLanguage(code: 'ja', englishName: 'Japanese', nativeName: '日本語'),
  AppLanguage(code: 'ko', englishName: 'Korean', nativeName: '한국어'),
  AppLanguage(code: 'ru', englishName: 'Russian', nativeName: 'Русский'),
  AppLanguage(code: 'pt', englishName: 'Portuguese', nativeName: 'Português'),
  AppLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
  AppLanguage(code: 'tr', englishName: 'Turkish', nativeName: 'Türkçe'),
  AppLanguage(code: 'it', englishName: 'Italian', nativeName: 'Italiano'),
  AppLanguage(code: 'ur', englishName: 'Urdu', nativeName: 'اردو', isRtl: true),
  AppLanguage(code: 'id', englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
];

/// A luxury glassmorphic modal bottom sheet for picking the app / player display language.
class LanguagePickerSheet extends StatelessWidget {
  final String currentLanguageCode;
  final ValueChanged<AppLanguage> onLanguageSelected;

  const LanguagePickerSheet({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  static AppLanguage getLanguage(String code) {
    return supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String currentLanguageCode,
    required ValueChanged<AppLanguage> onLanguageSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => LanguagePickerSheet(
        currentLanguageCode: currentLanguageCode,
        onLanguageSelected: onLanguageSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        color: Colors.cyanAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Player Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Translations are powered by easy_localization JSON files in assets/translations/.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: supportedLanguages.length,
                      separatorBuilder: (context, _) => const Divider(
                        color: Colors.white12,
                        height: 1,
                      ),
                      itemBuilder: (context, i) {
                        final lang = supportedLanguages[i];
                        final isSelected = lang.code == currentLanguageCode;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.cyanAccent.withValues(alpha: 0.22)
                                      : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.cyanAccent.withValues(alpha: 0.6)
                                        : Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  lang.code.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.cyanAccent
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            lang.nativeName,
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.cyanAccent : Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            ' ()',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.cyanAccent,
                                  size: 22,
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).pop();
                            onLanguageSelected(lang);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
