import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;
import '../domain/medical_item.dart';

/// Parses imported documents (.docx / .txt / .csv / .xls) and extracts
/// a list of [MedicalItem] names. This mirrors the desktop parsing that
/// was used to build the seed list, so users can import their own
/// supply lists at runtime.
///
/// Supported formats:
///  - .docx : unzips the OOXML and pulls text from word/document.xml
///  - .txt / .csv : one item per line (or comma-separated)
///  - .xls : reads the BIFF8/BIFF2 SST (shared string table) heuristically
///            for text cells. A best-effort parser for legacy .xls files.
class ImportService {
  ImportService._();
  static final ImportService instance = ImportService._();

  /// Detect format by extension and dispatch.
  Future<List<MedicalItem>> parseFile(String path) async {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'docx':
        return _parseDocx(path);
      case 'txt':
      case 'csv':
        return _parseText(File(path).readAsStringSync());
      case 'xls':
        return _parseXls(path);
      default:
        // Try text as a fallback
        return _parseText(File(path).readAsStringSync());
    }
  }

  // ---------- DOCX ----------
  Future<List<MedicalItem>> _parseDocx(String path) async {
    final bytes = File(path).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final docFile = archive.findFile('word/document.xml');
    if (docFile == null) return [];
    final content = utf8.decode(docFile.content as List<int>);
    final doc = xml.XmlDocument.parse(content);

    final items = <String>{};
    // Collect text inside each <w:t> and also join paragraph <w:p> runs.
    for (final para in doc.findAllElements('w:p')) {
      final text = para
          .findAllElements('w:t')
          .map((e) => e.innerText)
          .join('')
          .trim();
      if (text.isNotEmpty) {
        // A paragraph may list comma/slash separated items
        for (final part in text.split(RegExp(r'[,،;\n]+'))) {
          final cleaned = _cleanName(part);
          if (cleaned.isNotEmpty) items.add(cleaned);
        }
      }
    }

    final now = DateTime.now().toIso8601String();
    return items
        .map((name) => MedicalItem(
              itemName: name,
              category: 'Imported',
              createdAt: now,
              updatedAt: now,
            ))
        .toList();
  }

  // ---------- TEXT / CSV ----------
  List<MedicalItem> _parseText(String content) {
    final items = <String>{};
    for (final line in content.split(RegExp(r'[\n\r]+'))) {
      for (final part in line.split(RegExp(r'[,،;\t]+'))) {
        final cleaned = _cleanName(part);
        if (cleaned.isNotEmpty) items.add(cleaned);
      }
    }
    final now = DateTime.now().toIso8601String();
    return items
        .map((name) => MedicalItem(
              itemName: name,
              category: 'Imported',
              createdAt: now,
              updatedAt: now,
            ))
        .toList();
  }

  // ---------- XLS (legacy BIFF) ----------
  /// Best-effort reader for .xls files. Reads the Shared String Table
  /// (SST) records to extract text labels. Works for most supply lists
  /// that store item names as text cells.
  Future<List<MedicalItem>> _parseXls(String path) async {
    final bytes = File(path).readAsBytesSync();
    final items = <String>{};

    // Try UTF-16LE SST strings (record type 0x00FC) and also label
    // records (0x0204 / 0x00FD) with short strings.
    int i = 0;
    // First, locate the SST record.
    while (i + 4 < bytes.length) {
      final recType = _readU16(bytes, i);
      final recLen = _readU16(bytes, i + 2);
      if (recType == 0x00FC) {
        // SST record
        final sst = _parseSst(bytes, i + 4, recLen);
        for (final s in sst) {
          final cleaned = _cleanName(s);
          if (cleaned.isNotEmpty) items.add(cleaned);
        }
        break;
      }
      i += 4 + recLen;
      if (recLen == 0) break;
    }

    // Fallback: scan for LabelSst / Label records (0x0204, 0x00FD)
    if (items.isEmpty) {
      i = 0;
      while (i + 6 < bytes.length) {
        final recType = _readU16(bytes, i);
        final recLen = _readU16(bytes, i + 2);
        if (recType == 0x0204 || recType == 0x00FD) {
          // Label record: row(2), col(2), xf(2), str-len(1), options(1), str
          if (i + 8 < bytes.length) {
            final strLen = bytes[i + 8];
            final opt = bytes[i + 9];
            final isWide = (opt & 0x01) == 0x01;
            String text;
            if (isWide) {
              final sb = StringBuffer();
              for (var c = 0; c < strLen && (i + 10 + c * 2 + 1) < bytes.length; c++) {
                final code = _readU16(bytes, i + 10 + c * 2);
                sb.writeCharCode(code);
              }
              text = sb.toString();
            } else {
              final sb = StringBuffer();
              for (var c = 0; c < strLen && (i + 10 + c) < bytes.length; c++) {
                sb.writeCharCode(bytes[i + 10 + c]);
              }
              text = sb.toString();
            }
            final cleaned = _cleanName(text);
            if (cleaned.isNotEmpty) items.add(cleaned);
          }
        }
        i += 4 + recLen;
        if (recLen == 0) break;
      }
    }

    final now = DateTime.now().toIso8601String();
    return items
        .map((name) => MedicalItem(
              itemName: name,
              category: 'Imported',
              createdAt: now,
              updatedAt: now,
            ))
        .toList();
  }

  List<String> _parseSst(Uint8ListLike bytes, int offset, int len) {
    // cstUnique(4), cstCount(4), then array of XLUnicodeRichExtendedString
    if (offset + 8 > bytes.length) return [];
    final count = _readU32(bytes, offset);
    final strings = <String>[];
    var p = offset + 8;
    final end = offset + len;
    for (var n = 0; n < count && p < end; n++) {
      if (p + 3 > bytes.length) break;
      final strLen = _readU16(bytes, p);
      final opt = bytes[p + 2];
      final isWide = (opt & 0x01) == 0x01;
      final hasPhonetic = (opt & 0x04) == 0x04;
      final hasRich = (opt & 0x08) == 0x08;
      p += 3;
      int richRuns = 0;
      if (hasRich) {
        richRuns = _readU16(bytes, p);
        p += 2;
      }
      if (hasPhonetic) {
        p += 4; // phonetic size
      }
      final sb = StringBuffer();
      for (var c = 0; c < strLen; c++) {
        if (isWide) {
          if (p + 2 > bytes.length) break;
          sb.writeCharCode(_readU16(bytes, p));
          p += 2;
        } else {
          if (p >= bytes.length) break;
          sb.writeCharCode(bytes[p]);
          p += 1;
        }
      }
      strings.add(sb.toString());
      // skip rich text run data
      if (hasRich) {
        p += richRuns * 4;
      }
      // skip phonetic (size unknown precisely) — advance at least 0
    }
    return strings;
  }

  int _readU16(List<int> b, int off) => b[off] | (b[off + 1] << 8);
  int _readU32(List<int> b, int off) =>
      b[off] | (b[off + 1] << 8) | (b[off + 2] << 16) | (b[off + 3] << 24);

  /// Clean a raw cell/line into a usable item name.
  String _cleanName(String raw) {
    var s = raw.trim();
    // Strip trailing numeric ID codes like "1234" or "#123"
    s = s.replaceAll(RegExp(r'\s*#\d+\s*$'), '');
    s = s.replaceAll(RegExp(r'\s*\d{4,}\s*$'), '');
    // Remove control chars
    s = s.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    // Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

typedef Uint8ListLike = List<int>;
