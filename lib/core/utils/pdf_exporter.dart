import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/bidi_helper.dart';
import '../utils/docx_exporter.dart' show DocxRow;

/// Generates a PDF document for a medical request with correct Arabic
/// (right-to-left) rendering.
///
/// Arabic safety in PDF:
///  - The `pdf` package relies on ICU for BiDi reordering. We set
///    `textDirection: TextDirection.rtl` on every widget that contains
///    Arabic so the reordering is applied.
///  - We wrap Arabic strings with RLM marks (see [BidiHelper]) so mixed
///    Arabic + Latin + digits inside a cell keep their logical order.
///  - We embed the Cairo TrueType font from assets so Arabic glyphs are
///    shaped (the default Helvetica font cannot render Arabic).
class PdfExporter {
  PdfExporter._();

  static pw.Font? _cachedFont;

  /// Loads (and caches) the Cairo font from assets.
  static Future<pw.Font> _font() async {
    if (_cachedFont != null) return _cachedFont!;
    try {
      final data = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _cachedFont = pw.Font.ttf(data);
    } catch (_) {
      _cachedFont = pw.Font.helvetica();
    }
    return _cachedFont!;
  }

  static Future<Uint8List> build({
    required String title,
    required String date,
    required String department,
    required String requester,
    required String signature,
    required List<DocxRow> rows,
    String? footer,
  }) async {
    final font = await _font();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          _bidiText(
            title,
            style: pw.TextStyle(
                font: font,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800),
            align: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 12),
          _headerTable(font, date, department, requester, signature),
          pw.SizedBox(height: 16),
          _itemsTable(font, rows),
          pw.SizedBox(height: 20),
          if (footer != null && footer.isNotEmpty)
            _bidiText(
              footer,
              style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600),
            ),
          _bidiText(
            '© 2025 Abdullah Alshwerif (0917156449). All rights reserved.',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey400),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _headerTable(pw.Font font, String date, String department,
      String requester, String signature) {
    final rows = <pw.TableRow>[
      _headerRow('Date', date, font),
      _headerRow('Department', department, font),
      _headerRow('Requester', requester, font),
      if (signature.isNotEmpty) _headerRow('Signature', signature, font),
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      tableWidth: pw.TableWidth.max,
      children: rows,
    );
  }

  static pw.TableRow _headerRow(String label, String value, pw.Font font) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: _bidiText(
            label,
            style: pw.TextStyle(
                font: font,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: _bidiText(value, style: pw.TextStyle(font: font, fontSize: 11)),
        ),
      ],
    );
  }

  static pw.Widget _itemsTable(pw.Font font, List<DocxRow> rows) {
    final header = pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.blue800),
      children: [
        _headerCell('#', font),
        _headerCell('Item Name', font),
        _headerCell('Qty', font),
        _headerCell('Notes', font),
      ],
    );

    final dataRows = <pw.TableRow>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final isEven = i.isEven;
      dataRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColors.blue50),
          children: [
            _dataCell('${i + 1}', font, align: pw.TextAlign.center),
            _dataCell(r.itemName, font),
            _dataCell('${r.quantity}', font, align: pw.TextAlign.center),
            _dataCell(r.notes ?? '', font),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      tableWidth: pw.TableWidth.max,
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FlexColumnWidth(3),
      },
      children: [header, ...dataRows],
    );
  }

  static pw.Widget _headerCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: _bidiText(
        text,
        style: pw.TextStyle(
            font: font,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _dataCell(String text, pw.Font font,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: _bidiText(
        text,
        style: pw.TextStyle(font: font, fontSize: 10),
        align: align,
      ),
    );
  }

  /// A [pw.Text] that automatically picks RTL direction for Arabic and
  /// wraps the string with BiDi marks so it never renders "backward".
  static pw.Text _bidiText(
    String text, {
    required pw.TextStyle style,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final rtl = BidiHelper.isRtl(text);
    return pw.Text(
      BidiHelper.wrapForBiDi(text),
      style: style,
      textAlign: align == pw.TextAlign.left && rtl ? pw.TextAlign.right : align,
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    );
  }
}
