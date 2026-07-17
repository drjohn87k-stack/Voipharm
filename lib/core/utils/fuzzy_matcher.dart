/// Fuzzy string matching using Levenshtein edit distance.
/// Used together with SQL LIKE queries for robust item search
/// that tolerates partial or misspelled names.
class FuzzyMatcher {
  FuzzyMatcher._();

  /// Classic Levenshtein edit distance between [a] and [b].
  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    final aRunes = a.runes.toList();
    final bRunes = b.runes.toList();
    final aLen = aRunes.length;
    final bLen = bRunes.length;
    if (aLen == 0) return bLen;
    if (bLen == 0) return aLen;

    final prev = List<int>.generate(bLen + 1, (i) => i);
    final curr = List<int>.filled(bLen + 1, 0);

    for (int i = 1; i <= aLen; i++) {
      curr[0] = i;
      for (int j = 1; j <= bLen; j++) {
        final cost = aRunes[i - 1] == bRunes[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,        // deletion
          curr[j - 1] + 1,    // insertion
          prev[j - 1] + cost, // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
      prev.setRange(0, bLen + 1, curr);
    }
    return prev[bLen];
  }

  /// Similarity ratio in [0,1].
  static double similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1;
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 1;
    final dist = levenshtein(a, b);
    return 1 - (dist / maxLen);
  }

  /// True when [candidate] is a substring of [target] (case-insensitive)
  /// OR similarity exceeds [threshold].
  static bool matches({
    required String query,
    required String target,
    double threshold = 0.6,
  }) {
    final q = query.toLowerCase().trim();
    final t = target.toLowerCase().trim();
    if (q.isEmpty) return true;
    if (t.contains(q)) return true;
    // token-level match: any query token appears in target
    final qTokens = q.split(RegExp(r'\s+'));
    final tTokens = t.split(RegExp(r'\s+'));
    for (final qt in qTokens) {
      for (final tt in tTokens) {
        if (tt.startsWith(qt) && qt.length >= 3) return true;
        if (similarity(qt, tt) >= threshold) return true;
      }
    }
    return similarity(q, t) >= threshold;
  }

  /// Sort a list of strings by best fuzzy match to [query].
  static List<String> sortByRelevance(String query, Iterable<String> items) {
    final list = items.toList();
    list.sort((a, b) {
      final sa = similarity(query.toLowerCase(), a.toLowerCase());
      final sb = similarity(query.toLowerCase(), b.toLowerCase());
      return sb.compareTo(sa);
    });
    return list;
  }
}
