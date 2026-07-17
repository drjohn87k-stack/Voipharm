/// Helpers for handling bidirectional (Arabic/English mixed) text so that
/// Arabic never renders "backward" in exported Word (.docx) or PDF files.
///
/// The OOXML `<w:r>` runs and the PDF text drawers both rely on the *visual*
/// order of characters. For Arabic (a right-to-left script) to display
/// correctly we must:
///   1. Mark the paragraph / cell run as RTL (`bidi` / right-to-left).
///   2. Wrap any mixed-direction run with Unicode BiDi control characters
///      (RLM, LRM, RLE, LRE, PDF) so the Unicode Bidirectional Algorithm
///      lays characters out in the correct logical order.
///   3. Never reverse the string ourselves — let the renderer apply the
///      BiDi algorithm using the embedded controls.
class BidiHelper {
  BidiHelper._();

  // Unicode BiDi control characters.
  static const String _rlm = '\u200F'; // Right-to-Left Mark
  static const String _lrm = '\u200E'; // Left-to-Right Mark
  static const String _rle = '\u202B'; // Right-to-Left Embedding
  static const String _lre = '\u202A'; // Left-to-Right Embedding
  static const String _pdf = '\u202C'; // Pop Directional Format

  /// True if the string contains any Arabic character.
  static bool hasArabic(String s) {
    return s.runes.any((r) => r >= 0x0600 && r <= 0x06FF || r >= 0xFB50 && r <= 0xFEFF);
  }

  /// Returns the dominant paragraph direction for [s].
  static bool isRtl(String s) {
    // Count first strong directional character.
    for (final r in s.runes) {
      if (r >= 0x0600 && r <= 0x06FF) return true; // Arabic
      if (r >= 0x0041 && r <= 0x007A) return false; // Latin
    }
    return false;
  }

  /// Wraps the text so the BiDi algorithm lays it out correctly inside a
  /// run whose direction is already set. Use this for cell content that
  /// may mix Arabic + Latin + digits.
  static String wrapForBiDi(String s) {
    if (s.isEmpty) return s;
    if (!hasArabic(s)) return '$_lrm$s$_lrm';
    // Embed RTL for the whole run; Latin/digits inside will still be LTR
    // thanks to the BiDi algorithm.
    return '$_rle$s$_pdf$_rlm';
  }

  /// Returns the property value to set on an OOXML run:
  /// `<w:rPr><w:rtl/></w:rPr>` is needed when the run's dominant
  /// direction is RTL.
  static bool runNeedsRtl(String s) => isRtl(s);

  /// Returns the alignment value for a paragraph containing [s].
  /// 'right' for Arabic, 'left' for Latin, 'start' otherwise.
  static String paragraphAlign(String s) {
    if (isRtl(s)) return 'right';
    return 'left';
  }

  /// Prepend an RLM so trailing Latin/digits don't get pulled to the right
  /// edge of an Arabic cell.
  static String secureArabic(String s) {
    if (hasArabic(s) && !s.endsWith(_rlm)) {
      return '$s$_rlm';
    }
    return s;
  }

  /// Expose the raw control chars for the DOCX builder (rarely needed).
  static String get rlm => _rlm;
  static String get lrm => _lrm;
  static String get rle => _rle;
  static String get lre => _lre;
  static String get pdf => _pdf;
}
