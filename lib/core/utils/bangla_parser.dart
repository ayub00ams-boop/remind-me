class BanglaParser {
  static const _digitMap = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  static const _timePeriods = {
    'ভোর': [4, 0],
    'সকাল': [6, 0],
    'দুপুর': [12, 0],
    'বিকাল': [15, 0],
    'সন্ধ্যা': [18, 0],
    'রাত': [21, 0],
    'দেরি রাত': [22, 0],
  };

  static String normalizeBanglaDigits(String text) {
    return text.replaceAllMapped(
      RegExp(r'[০-৯]'),
      (match) => _digitMap[match.group(0)] ?? match.group(0)!,
    );
  }

  static String sanitizeText(String input) {
    return input
        .replaceFirst(RegExp(r'^(amake|আমাকে|remind me|please)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(remember|remind|mone\s+koriye|mone\s+kora[iy]ba|bolba)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'(কথা\s+)?মনে\s+কর(াইবা|াইবে|াবে)|মনে\s+রাখবা|বলবা'), '')
        .replaceFirst(RegExp(r'^(to|that|j[eé]no|যে)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static ParsedReminder? parseRelativeReminder(String text, {DateTime? now}) {
    now ??= DateTime.now();
    final normalized = normalizeBanglaDigits(text.toLowerCase());
    
    final minuteMatch = RegExp(
      r'(\d+)\s*(minute|min|minutes|মিনিট)\s*(por|later|পরে)',
      caseSensitive: false,
    ).firstMatch(normalized);

    if (minuteMatch != null) {
      final minutes = int.tryParse(minuteMatch.group(1)!);
      if (minutes == null || minutes < 1) return null;

      final remindAt = now.add(Duration(minutes: minutes));
      final title = sanitizeText(
        normalized.replaceFirst(minuteMatch.group(0)!, '').replaceFirst(
          RegExp(r'\b(in|after|amake|আমাকে)\b', caseSensitive: false), '',
        ),
      );

      return ParsedReminder(
        title: title.isEmpty ? 'Reminder after $minutes minutes' : title,
        remindAt: remindAt,
        type: ReminderType.relative,
        minutes: minutes,
      );
    }

    final hourMatch = RegExp(
      r'(\d+)\s*(hour|hrs?|hours|ঘণ্টা)\s*(por|later|পরে)',
      caseSensitive: false,
    ).firstMatch(normalized);

    if (hourMatch != null) {
      final hours = int.tryParse(hourMatch.group(1)!);
      if (hours == null || hours < 1) return null;

      final remindAt = now.add(Duration(hours: hours));
      final title = sanitizeText(
        normalized.replaceFirst(hourMatch.group(0)!, '').replaceFirst(
          RegExp(r'\b(in|after|amake|আমাকে)\b', caseSensitive: false), '',
        ),
      );

      return ParsedReminder(
        title: title.isEmpty ? 'Reminder after $hours hours' : title,
        remindAt: remindAt,
        type: ReminderType.relative,
        minutes: hours * 60,
      );
    }

    return null;
  }

  static ParsedReminder? parseAbsoluteReminder(String text, {DateTime? now}) {
    now ??= DateTime.now();
    final normalized = normalizeBanglaDigits(text.toLowerCase());

    for (final entry in _timePeriods.entries) {
      if (normalized.contains(entry.key)) {
        final hour = entry.value[0];
        final minute = entry.value[1];
        
        var remindAt = DateTime(now.year, now.month, now.day, hour, minute);
        if (remindAt.isBefore(now)) {
          remindAt = remindAt.add(const Duration(days: 1));
        }

        final title = sanitizeText(
          normalized.replaceFirst(entry.key, ''),
        );

        return ParsedReminder(
          title: title.isEmpty ? 'Reminder at ${entry.key}' : title,
          remindAt: remindAt,
          type: ReminderType.absolute,
        );
      }
    }

    final timeMatch = RegExp(
      r'(?:at|e|এ|টা[য়y]?|টার\s+সময়)?\s*(\d{1,2})[:\.](\d{2})',
      caseSensitive: false,
    ).firstMatch(normalized);

    if (timeMatch != null) {
      final hours = int.tryParse(timeMatch.group(1)!);
      final minutes = int.tryParse(timeMatch.group(2)!);
      if (hours == null || minutes == null) return null;
      if (hours > 23 || minutes > 59) return null;

      var remindAt = DateTime(now.year, now.month, now.day, hours, minutes);
      if (remindAt.isBefore(now)) {
        remindAt = remindAt.add(const Duration(days: 1));
      }

      final title = sanitizeText(
        normalized.replaceFirst(timeMatch.group(0)!, '').replaceFirst(
          RegExp(r'\b(at|e|amake|আমাকে)\b', caseSensitive: false), '',
        ),
      );

      return ParsedReminder(
        title: title.isEmpty 
            ? 'Reminder at ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}' 
            : title,
        remindAt: remindAt,
        type: ReminderType.absolute,
      );
    }

    return null;
  }

  static ParsedReminder? parse(String text, {DateTime? now}) {
    return parseRelativeReminder(text, now: now) ?? parseAbsoluteReminder(text, now: now);
  }
}

enum ReminderType { relative, absolute }

class ParsedReminder {
  final String title;
  final DateTime remindAt;
  final ReminderType type;
  final int? minutes;

  ParsedReminder({
    required this.title,
    required this.remindAt,
    required this.type,
    this.minutes,
  });
}