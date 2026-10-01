import 'package:flutter/material.dart';

import '../data/demo_catalog.dart';
import '../models/demo_showcase_item.dart';
import '../widgets/creative_demo_card.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/stat_pill.dart';

/// Main catalog showcase screen for demonstrating players and features
class ShowcaseScreen extends StatefulWidget {
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

  bool get isRtl => LanguagePickerSheet.getLanguage(currentLanguageCode).isRtl;

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'YouTube',
    'Direct Stream',
    'HLS Live',
    'Captions',
  ];

  late final List<DemoShowcaseItem> _allDemos;

  @override
  void initState() {
    super.initState();
    _allDemos = getDemoShowcaseItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final currentLang = LanguagePickerSheet.getLanguage(widget.currentLanguageCode);
    final filteredDemos = _selectedCategory == 'All'
        ? _allDemos
        : _allDemos.where((d) => d.category == _selectedCategory).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Floating Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              // Language Selector Button
              InkWell(
                onTap: () {
                  LanguagePickerSheet.show(
                    context,
                    currentLanguageCode: widget.currentLanguageCode,
                    onLanguageSelected: (lang) =>
                        widget.onSelectLanguage(lang.code),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        size: 15,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentLang.code.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amberAccent : Colors.indigo,
                ),
                onPressed: widget.onToggleTheme,
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E1B4B),
                            const Color(0xFF0F172A),
                            const Color(0xFF020617),
                          ]
                        : [
                            const Color(0xFFEEF2FF),
                            const Color(0xFFE0E7FF),
                            const Color(0xFFF8FAFC),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: (MediaQuery.sizeOf(context).width - 40)
                              .clamp(160.0, 1200.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF6366F1)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: Color(0xFF818CF8),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'v1.0.0 Ready',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF818CF8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatPill(
                                    label: 'Quality',
                                    value: 'Multi-Res',
                                    icon: Icons.hd_rounded,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  StatPill(
                                    label: 'Language',
                                    value: currentLang.nativeName,
                                    icon: Icons.language_rounded,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Adaptive Video Player Studio',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'VOD, Live Streams, YouTube, and multi-language localization via PlayerTextConfig',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Categories Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: const Color(0xFF6366F1),
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04),
                        showCheckmark: false,
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.04)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Cards List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: filteredDemos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final demo = filteredDemos[index];
                return CreativeDemoCard(
                  demo: demo,
                  isDark: isDark,
                  currentLanguageCode: widget.currentLanguageCode,
                  onSelectLanguage: widget.onSelectLanguage,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
