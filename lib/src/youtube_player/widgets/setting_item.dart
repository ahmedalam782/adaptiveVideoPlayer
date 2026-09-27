import 'package:flutter/material.dart';

/// Individual setting item widget for YouTube player settings
class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color? switchInactiveThumbColor;
  final Color? switchInactiveTrackColor;
  final TextStyle? textStyle;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    this.switchInactiveThumbColor,
    this.switchInactiveTrackColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor.withValues(alpha: 0.7), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: textStyle ??
                  TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) => onChanged(val),
            inactiveThumbColor: switchInactiveThumbColor,
            inactiveTrackColor: switchInactiveTrackColor,
          ),
        ],
      ),
    );
  }
}
