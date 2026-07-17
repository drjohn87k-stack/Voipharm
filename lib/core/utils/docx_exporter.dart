import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../utils/bidi_helper.dart';

/// Generates a Microsoft Word (.docx) document using raw OOXML.
///
/// RTL / Arabic safety:
///  - Every paragraph containing Arabic gets `<w:bidi/>` + right alignment.
///  - Every run whose text is RTL gets `<w:rtl/>` in its run properties so
///    Word applies the Unicode BiDi algorithm correctly.
///  - Mixed Arabic + Latin + digits inside a single cell are wrapped with
///    BiDi control characters via [BidiHelper.wrapForBiDi].
///
/// The result is a bordered table with header info + item rows and
/// alternating row colors, identical to a hand-made Word document.
class DocxExporter {
  DocxExporter._();

  /// Build the .docx bytes for a medical request.
  static Uint8List build({
    required String title,
    required String date,
    required String department,
    required String requester,
    required String signature,
    required List<DocxRow> rows,
    String? footer,
  }) {
    final archive = Archive();

    // ---- [Content_Types].xml ----
    archive.addFile(ArchiveFile.string(
      '[Content_Types].xml',
      _contentTypes,
    ));

    // ---- _rels/.rels ----
    archive.addFile(ArchiveFile.string(
      '_rels/.rels',
      _rootRels,
    ));

    // ---- word/_rels/document.xml.rels ----
    archive.addFile(ArchiveFile.string(
      'word/_rels/document.xml.rels',
      _documentRels,
    ));

    // ---- word/styles.xml ----
    archive.addFile(ArchiveFile.string(
      'word/styles.xml',
      _stylesXml,
    ));

    // ---- word/document.xml ----
    archive.addFile(ArchiveFile.string(
      'word/document.xml',
      _buildDocument(
        title: title,
        date: date,
        department: department,
        requester: requester,
        signature: signature,
        rows: rows,
        footer: footer,
      ),
    ));

    final encoder = ZipEncoder();
    final bytes = encoder.encode(archive)!;
    return Uint8List.fromList(bytes);
  }

  static String _escape(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Build a single run with correct RTL properties for [text].
  static String _run(String text,
      {bool bold = false, double size = 22, String color = '000000'}) {
    final rtl = BidiHelper.runNeedsRtl(text);
    final wrapped = BidiHelper.wrapForBiDi(text);
    final esc = _escape(wrapped);
    final rpr = StringBuffer('<w:rPr>');
    rpr.write('<w:rFonts w:ascii="Cairo" w:hAnsi="Cairo" '
        'w:cs="Cairo" w:hint="default"/>');
    rpr.write('<w:sz w:val="${(size * 2).round()}"/>');
    rpr.write('<w:szCs w:val="${(size * 2).round()}"/>');
    rpr.write('<w:color w:val="$color"/>');
    if (bold) rpr.write('<w:b/><w:bCs/>');
    if (rtl) rpr.write('<w:rtl/>');
    rpr.write('</w:rPr>');
    return '<w:r>$rpr<w:t xml:space="preserve">$esc</w:t></w:r>';
  }

  /// Build a paragraph. If the text is Arabic, set bidi + right align.
  static String _paragraph(String text,
      {bool bold = false,
      double size = 22,
      String color = '000000',
      String align = 'auto'}) {
    final rtl = BidiHelper.isRtl(text);
    final ppr = StringBuffer('<w:pPr>');
    if (align == 'auto') {
      if (rtl) {
        ppr.write('<w:bidi/>');
        ppr.write('<w:jc w:val="right"/>');
      } else {
        ppr.write('<w:jc w:val="left"/>');
      }
    } else {
      ppr.write('<w:jc w:val="$align"/>');
      if (rtl) ppr.write('<w:bidi/>');
    }
    ppr.write('</w:pPr>');
    return '<w:p>$ppr${_run(text, bold: bold, size: size, color: color)}</w:p>';
  }

  /// Build a table cell with optional shading + width.
  static String _cell(String text,
      {required String shading,
      bool bold = false,
      double size = 22,
      String color = '000000',
      String width = '2000',
      String vAlign = 'center'}) {
    final rtl = BidiHelper.isRtl(text);
    final ppr = StringBuffer('<w:pPr>');
    if (rtl) {
      ppr.write('<w:bidi/><w:jc w:val="right"/>');
    } else {
      ppr.write('<w:jc w:val="left"/>');
    }
    ppr.write('<w:spacing w:after="0" w:line="240" w:lineRule="auto"/>');
    ppr.write('</w:pPr>');
    final run = _run(text, bold: bold, size: size, color: color);
    return '''
<w:tc>
  <w:tcPr>
    <w:tcW w:w="$width" w:type="dxa"/>
    <w:shd w:val="clear" w:color="auto" w:fill="$shading"/>
    <w:vAlign w:val="$vAlign"/>
    <w:tcBorders>
      <w:top w:val="single" w:sz="4" w:space="0" w:color="666666"/>
      <w:left w:val="single" w:sz="4" w:space="0" w:color="666666"/>
      <w:bottom w:val="single" w:sz="4" w:space="0" w:color="666666"/>
      <w:right w:val="single" w:sz="4" w:space="0" w:color="666666"/>
    </w:tcBorders>
  </w:tcPr>
  <w:p>$ppr$run</w:p>
</w:tc>''';
  }

  static String _buildDocument({
    required String title,
    required String date,
    required String department,
    required String requester,
    required String signature,
    required List<DocxRow> rows,
    String? footer,
  }) {
    final body = StringBuffer();

    // Title
    body.write(_paragraph(title, bold: true, size: 32, color: '1976D2',
        align: 'center'));
    body.write('<w:p/>');

    // Header info table (2 columns: label, value)
    body.write(_headerRow('Title', title));
    body.write(_headerRow('Date', date));
    body.write(_headerRow('Department', department));
    body.write(_headerRow('Requester', requester));
    if (signature.isNotEmpty) body.write(_headerRow('Signature', signature));
    body.write('<w:p/>');

    // Items table
    final headerRow = '''
<w:tr>
  ${_cell('#', shading: '1976D2', bold: true, color: 'FFFFFF', width: '600')}
  ${_cell('Item Name', shading: '1976D2', bold: true, color: 'FFFFFF', width: '4200')}
  ${_cell('Qty', shading: '1976D2', bold: true, color: 'FFFFFF', width: '900')}
  ${_cell('Notes', shading: '1976D2', bold: true, color: 'FFFFFF', width: '3000')}
</w:tr>''';

    final dataRows = StringBuffer();
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final shade = i.isEven ? 'FFFFFF' : 'EAF2FB';
      dataRows.write('''
<w:tr>
  ${_cell('${i + 1}', shading: shade, width: '600')}
  ${_cell(r.itemName, shading: shade, width: '4200')}
  ${_cell('${r.quantity}', shading: shade, width: '900')}
  ${_cell(r.notes ?? '', shading: shade, width: '3000')}
</w:tr>''');
    }

    body.write('''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="8700" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="6" w:space="0" w:color="1976D2"/>
      <w:left w:val="single" w:sz="6" w:space="0" w:color="1976D2"/>
      <w:bottom w:val="single" w:sz="6" w:space="0" w:color="1976D2"/>
      <w:right w:val="single" w:sz="6" w:space="0" w:color="1976D2"/>
      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="666666"/>
      <w:insideV w:val="single" w:sz="4" w:space="0" w:color="666666"/>
    </w:tblBorders>
    <w:tblLayout w:type="fixed"/>
  </w:tblPr>
  <w:tblGrid>
    <w:gridCol w:w="600"/>
    <w:gridCol w:w="4200"/>
    <w:gridCol w:w="900"/>
    <w:gridCol w:w="3000"/>
  </w:tblGrid>
  $headerRow
  $dataRows
</w:tbl>''');

    body.write('<w:p/>');
    if (footer != null && footer.isNotEmpty) {
      body.write(_paragraph(footer, size: 18, color: '666666'));
    }
    // Copyright footer
    body.write(_paragraph(
      '© 2025 Abdullah Alshwerif (0917156449). All rights reserved.',
      size: 16,
      color: '999999',
    ));

    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134"
               w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>''';
  }

  /// A two-column label/value row rendered as a 1-row table.
  static String _headerRow(String label, String value) {
    final labelRtl = BidiHelper.isRtl(label);
    final valueRtl = BidiHelper.isRtl(value);
    String lpPr(String text) {
      final p = StringBuffer('<w:pPr>');
      if (BidiHelper.isRtl(text)) {
        p.write('<w:bidi/><w:jc w:val="right"/>');
      } else {
        p.write('<w:jc w:val="left"/>');
      }
      p.write('</w:pPr>');
      return p.toString();
    }

    return '''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="8700" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
      <w:left w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
      <w:bottom w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
      <w:right w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
      <w:insideV w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
    </w:tblBorders>
    <w:tblLayout w:type="fixed"/>
  </w:tblPr>
  <w:tblGrid>
    <w:gridCol w:w="2200"/>
    <w:gridCol w:w="6500"/>
  </w:tblGrid>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="2200" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="EAF2FB"/>
        <w:tcBorders>
          <w:top w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
          <w:left w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
          <w:bottom w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
          <w:right w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
        </w:tcBorders>
      </w:tcPr>
      <w:p>${lpPr(label)}${_run(label, bold: true, size: 22, color: '1976D2')}</w:p>
    </w:tc>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="6500" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="FFFFFF"/>
        <w:tcBorders>
          <w:top w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
          <w:left w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
          <w:bottom w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
          <w:right w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>
        </w:tcBorders>
      </w:tcPr>
      <w:p>${lpPr(value)}${_run(value, size: 22)}</w:p>
    </w:tc>
  </w:tr>
</w:tbl>
<!-- keep labelRtl/valueRtl used to avoid lint -->
${labelRtl ? '' : ''}${valueRtl ? '' : ''}''';
  }

  // ---- Static OOXML scaffolding ----
  static const String _contentTypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>''';

  static const String _rootRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  static const String _documentRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''';

  static const String _stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Cairo" w:hAnsi="Cairo" w:cs="Cairo"/>
        <w:sz w:val="22"/>
        <w:szCs w:val="22"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
</w:styles>''';
}

/// A single row in the exported document.
class DocxRow {
  const DocxRow({
    required this.itemName,
    required this.quantity,
    this.notes,
  });
  final String itemName;
  final int quantity;
  final String? notes;
}
