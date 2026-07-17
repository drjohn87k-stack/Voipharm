/// Parses spoken number words into integers.
/// Supports Arabic (صفر، واحد، عشرون...) and English (one, twenty...)
/// including compound numbers ("twenty-one", "واحد وعشرون", "مئة وخمسة").
class NumberParser {
  NumberParser._();

  // ---- English ----
  static const Map<String, int> _enUnits = {
    'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
    'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14,
    'fifteen': 15, 'sixteen': 16, 'seventeen': 17, 'eighteen': 18,
    'nineteen': 19,
  };
  static const Map<String, int> _enTens = {
    'twenty': 20, 'thirty': 30, 'forty': 40, 'fourty': 40, 'fifty': 50,
    'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90,
  };
  static const Map<String, int> _enScales = {
    'hundred': 100, 'thousand': 1000,
  };

  // ---- Arabic ----
  static const Map<String, int> _arUnits = {
    'صفر': 0,
    'واحد': 1, 'واحدة': 1, 'واحده': 1,
    'اثنان': 2, 'اثنين': 2, 'إثنان': 2, 'إثنين': 2,
    'ثلاثة': 3, 'ثلاثه': 3, 'ثلاث': 3,
    'أربعة': 4, 'اربعة': 4, 'أربعه': 4, 'اربعه': 4,
    'خمسة': 5, 'خمسه': 5, 'خمس': 5,
    'ستة': 6, 'سته': 6, 'ست': 6,
    'سبعة': 7, 'سبعه': 7, 'سبع': 7,
    'ثمانية': 8, 'ثمانيه': 8, 'ثماني': 8,
    'تسعة': 9, 'تسعه': 9, 'تسع': 9,
    'عشرة': 10, 'عشره': 10, 'عشر': 10,
    'أحد عشر': 11, 'احد عشر': 11, 'أحدعشر': 11, 'احدعشر': 11,
    'اثنا عشر': 12, 'اثنان عشر': 12, 'إثنا عشر': 12,
    'اثنا عشرا': 12,
  };
  static const Map<String, int> _arTens = {
    'عشرون': 20, 'عشرين': 20,
    'ثلاثون': 30, 'ثلاثين': 30,
    'أربعون': 40, 'اربعون': 40, 'أربعين': 40, 'اربعين': 40,
    'خمسون': 50, 'خمسين': 50,
    'ستون': 60, 'ستين': 60,
    'سبعون': 70, 'سبعين': 70,
    'ثمانون': 80, 'ثمانين': 80,
    'تسعون': 90, 'تسعين': 90,
  };
  static const Map<String, int> _arScales = {
    'مئة': 100, 'مئه': 100, 'مائة': 100, 'مئتان': 200,
    'ألف': 1000, 'الف': 1000,
  };

  /// Parse a spoken/written phrase into an integer.
  /// Returns null if nothing numeric is found.
  static int? parse(String input, {String language = 'en'}) {
    if (input.isEmpty) return null;
    final trimmed = input.trim();

    // 1) Plain digits ("5", "073")
    final digitMatch = RegExp(r'\d+').firstMatch(trimmed);
    if (digitMatch != null) {
      final n = int.tryParse(digitMatch.group(0)!);
      if (n != null) return n;
    }

    // 2) Word-based
    if (language == 'ar') {
      return _parseArabic(trimmed);
    }
    return _parseEnglish(trimmed);
  }

  static int? _parseEnglish(String text) {
    final lower = text.toLowerCase().replaceAll('-', ' ');
    final tokens = lower
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;

    int total = 0;
    int current = 0;
    bool foundAny = false;

    for (final tok in tokens) {
      if (_enUnits.containsKey(tok)) {
        current += _enUnits[tok]!;
        foundAny = true;
      } else if (_enTens.containsKey(tok)) {
        current += _enTens[tok]!;
        foundAny = true;
      } else if (_enScales.containsKey(tok)) {
        final scale = _enScales[tok]!;
        current = (current == 0 ? 1 : current) * scale;
        if (scale >= 1000) {
          total += current;
          current = 0;
        }
        foundAny = true;
      } else if (tok == 'and') {
        // skip "and"
      }
    }
    total += current;
    return foundAny ? total : null;
  }

  static int? _parseArabic(String text) {
    // Normalize: remove diacritics, unify alef variants for matching
    final cleaned = text
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // tashkeel
        .replaceAll('ـ', ''); // tatweel

    // Try multi-word compound first
    int? compound = _parseArabicCompound(cleaned);
    if (compound != null) return compound;

    final tokens = cleaned
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;

    int total = 0;
    int current = 0;
    bool foundAny = false;

    for (final tok in tokens) {
      final t = _normalizeAlef(tok);
      if (_arUnits.containsKey(t)) {
        current += _arUnits[t]!;
        foundAny = true;
      } else if (_arTens.containsKey(t)) {
        current += _arTens[t]!;
        foundAny = true;
      } else if (_arScales.containsKey(t)) {
        if (t == 'مئتان' || t == 'مئتين') {
          current += 200;
        } else {
          current = (current == 0 ? 1 : current) * (_arScales[t]!);
        }
        foundAny = true;
      } else if (t == 'و') {
        // skip conjunction
      }
    }
    total += current;
    return foundAny ? total : null;
  }

  /// Handle common Arabic compounds like "واحد وعشرون" (21), "ثلاث مئة" (300).
  static int? _parseArabicCompound(String text) {
    // "X و Y" where Y is a tens word  -> X + Y
    final m = RegExp(r'(.+?)\s*و\s*(عشرون|عشرين|ثلاثون|ثلاثين|أربعون|اربعون|أربعين|اربعين|خمسون|خمسين|ستون|ستين|سبعون|سبعين|ثمانون|ثمانين|تسعون|تسعين)')
        .firstMatch(text);
    if (m != null) {
      final left = _parseArabic(m.group(1)!.trim());
      final tens = _arTens[_normalizeAlef(m.group(2)!)];
      if (left != null && tens != null) return left + tens;
      if (tens != null && left == null) return tens;
    }
    return null;
  }

  static String _normalizeAlef(String s) {
    return s
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');
  }
}
