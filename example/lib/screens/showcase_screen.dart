import 'package:flutter/material.dart';

import '../data/demo_catalog.dart';
import '../models/demo_showcase_item.dart';
import '../widgets/creative_demo_card.dart';
import '../widgets/stat_pill.dart';

/// Main catalog showcase screen for demonstrating players and features
class ShowcaseScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final bool isRtl;
  final VoidCallback onToggleLanguage;

  const ShowcaseScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.isRtl,
    required this.onToggleLanguage,
  });

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Arabic / RTL',
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
            expandedHeight: 250,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: widget.isRtl
                    ? 'Switch to English (LTR)'
                    : 'التبديل إلى العربية (RTL)',
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                icon: Text(
                  widget.isRtl ? 'EN' : 'عربي',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                  ),
                ),
                onPressed: widget.onToggleLanguage,
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
                            const Color(0xFF1E1B4B).withValues(alpha: 0.7),
                            const Color(0xFF0F172A).withValues(alpha: 0.9),
                            theme.scaffoldBackgroundColor,
                          ]
                        : [
                            const Color(0xFFEEF2FF),
                            const Color(0xFFF1F5F9),
                            theme.scaffoldBackgroundColor,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Version & Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'v2.0.0 • Pure ValueNotifier • 0 Dependencies',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          'Adaptive Video Player',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'YouTube & Direct URLs in one seamless, cross-platform engine.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.65)
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

          // Feature Highlights Strip
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  StatPill(
                    icon: Icons.devices_rounded,
                    label: '6 Platforms',
                    value: 'Web, Win, Mac, Linux, Mobile',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  StatPill(
                    icon: Icons.bolt_rounded,
                    label: 'Ultra Light',
                    value: 'Native ValueNotifier',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  StatPill(
                    icon: Icons.tune_rounded,
                    label: 'Adaptive UI',
                    value: 'Live CC & Quality Picker',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  StatPill(
                    icon: Icons.touch_app_rounded,
                    label: 'Gestures',
                    value: 'Double-Tap ±10s Seek',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                        showCheckmark: false,
                        selectedColor: const Color(0xFF6366F1),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                            : const Color(0xFFE2E8F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
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
                  onToggleLanguage: widget.onToggleLanguage,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
