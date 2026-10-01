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
  AppLanguage(code: 'tr', englishName: 'Turkish', nativeName: 'Türkçe'),
  AppLanguage(code: 'es', englishName: 'Spanish', nativeName: 'Español'),
  AppLanguage(code: 'fr', englishName: 'French', nativeName: 'Français'),
  AppLanguage(code: 'de', englishName: 'German', nativeName: 'Deutsch'),
];

/// Interactive bottom sheet for choosing the application language.
/// Demonstrates how host applications allow users to pick a language
/// and dynamically apply localized PlayerTextConfig via easy_localization.
class LanguagePickerSheet extends StatelessWidget {
  final String currentLanguageCode;
  final ValueChanged<AppLanguage> onLanguageSelected;

  const LanguagePickerSheet({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  /// Resolves an [AppLanguage] descriptor by its ISO language code.
  static AppLanguage getLanguage(String? code) {
    if (code == null) return supportedLanguages.first;
    final clean = code.trim().toLowerCase();
    return supportedLanguages.firstWhere(
      (lang) => lang.code == clean,
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
      backgroundColor: const Color(0xFF111726),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LanguagePickerSheet(
        currentLanguageCode: currentLanguageCode,
        onLanguageSelected: onLanguageSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.cyanAccent.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
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
                      '${lang.englishName} (${lang.isRtl ? 'RTL' : 'LTR'})',
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
    );
  }
}
