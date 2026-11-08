class SubtitleItem {
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleItem({
    required this.start,
    required this.end,
    required this.text,
  });
}

class SubtitleParser {
  static List<SubtitleItem> parse(String content) {
    if (content.trimLeft().startsWith('WEBVTT')) {
      return _parseVtt(content);
    }
    return _parseSrt(content);
  }

  static List<SubtitleItem> _parseSrt(String content) {
    final List<SubtitleItem> items = [];
    final blocks = content.replaceAll('\r\n', '\n').split('\n\n');

    for (var block in blocks) {
      if (block.trim().isEmpty) continue;

      final lines = block.trim().split('\n');
      if (lines.length >= 3) {
        final timeLine = lines[1];
        if (timeLine.contains('-->')) {
          final parts = timeLine.split('-->');
          if (parts.length == 2) {
            final start = _parseSrtTime(parts[0].trim());
            final end = _parseSrtTime(parts[1].trim());
            final text = lines.sublist(2).join('\n');
            items.add(SubtitleItem(start: start, end: end, text: text));
          }
        }
      } else if (lines.length >= 2) {
        // Sometimes index is missing
        int timeIndex = lines.indexWhere((l) => l.contains('-->'));
        if (timeIndex != -1 && timeIndex + 1 < lines.length) {
          final parts = lines[timeIndex].split('-->');
          if (parts.length == 2) {
            final start = _parseSrtTime(parts[0].trim());
            final end = _parseSrtTime(parts[1].trim());
            final text = lines.sublist(timeIndex + 1).join('\n');
            items.add(SubtitleItem(start: start, end: end, text: text));
          }
        }
      }
    }
    return items;
  }

  static List<SubtitleItem> _parseVtt(String content) {
    final List<SubtitleItem> items = [];
    final blocks = content.replaceAll('\r\n', '\n').split('\n\n');

    for (var block in blocks) {
      if (block.trim().isEmpty || block.trim().startsWith('WEBVTT')) continue;

      final lines = block.trim().split('\n');
      int timeLineIndex = -1;

      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          timeLineIndex = i;
          break;
        }
      }

      if (timeLineIndex != -1 && timeLineIndex + 1 < lines.length) {
        final timeLine = lines[timeLineIndex];
        final parts = timeLine.split('-->');
        if (parts.length == 2) {
          final start = _parseVttTime(parts[0].trim().split(' ')[0]);
          final end = _parseVttTime(parts[1].trim().split(' ')[0]);
          final text = lines.sublist(timeLineIndex + 1).join('\n');
          // Strip simple HTML tags from VTT
          items.add(
            SubtitleItem(
              start: start,
              end: end,
              text: text.replaceAll(RegExp(r'<[^>]*>'), ''),
            ),
          );
        }
      }
    }
    return items;
  }

  static Duration _parseSrtTime(String timeString) {
    // 00:00:20,000
    final parts = timeString.replaceAll(',', '.').split(':');
    if (parts.length != 3) return Duration.zero;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    final secParts = parts[2].split('.');
    final seconds = int.tryParse(secParts[0]) ?? 0;
    final milliseconds = secParts.length > 1
        ? int.tryParse(secParts[1].padRight(3, '0').substring(0, 3)) ?? 0
        : 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  static Duration _parseVttTime(String timeString) {
    // 00:00:20.000 or 00:20.000
    final parts = timeString.split(':');
    int hours = 0;
    int minutes = 0;
    String secStr = '';
    if (parts.length == 3) {
      hours = int.tryParse(parts[0]) ?? 0;
      minutes = int.tryParse(parts[1]) ?? 0;
      secStr = parts[2];
    } else if (parts.length == 2) {
      minutes = int.tryParse(parts[0]) ?? 0;
      secStr = parts[1];
    }

    final secParts = secStr.split('.');
    final seconds = int.tryParse(secParts[0]) ?? 0;
    final milliseconds = secParts.length > 1
        ? int.tryParse(secParts[1].padRight(3, '0').substring(0, 3)) ?? 0
        : 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
