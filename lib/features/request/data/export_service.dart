import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/docx_exporter.dart';
import '../../../core/utils/pdf_exporter.dart';
import '../domain/request_entity.dart';

/// Wraps the DOCX / PDF exporters and handles saving to a temp file
/// and sharing via the platform share sheet.
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// Build a [DocxRow] list from a request's items.
  List<DocxRow> _rows(RequestEntity request) =>
      request.items
          .map((i) => DocxRow(
                itemName: i.itemName,
                quantity: i.quantity,
                notes: i.notes,
              ))
          .toList();

  String _safeFileName(String base) {
    final safe = base.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return safe.isEmpty ? 'medical_request' : safe;
  }

  /// Export to Word (.docx) and share.
  Future<File> exportDocx(RequestEntity request) async {
    final title = request.title ?? 'Medical Request ${request.date ?? ''}';
    final bytes = DocxExporter.build(
      title: title,
      date: request.date ?? '',
      department: request.department ?? '',
      requester: request.requester ?? '',
      signature: request.signature ?? '',
      rows: _rows(request),
      footer:
          '© 2025 Abdullah Alshwerif (0917156449). All rights reserved.',
    );
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, '${_safeFileName(title)}.docx'));
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Export to PDF and share.
  Future<File> exportPdf(RequestEntity request) async {
    final title = request.title ?? 'Medical Request ${request.date ?? ''}';
    final bytes = await PdfExporter.build(
      title: title,
      date: request.date ?? '',
      department: request.department ?? '',
      requester: request.requester ?? '',
      signature: request.signature ?? '',
      rows: _rows(request),
      footer:
          '© 2025 Abdullah Alshwerif (0917156449). All rights reserved.',
    );
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, '${_safeFileName(title)}.pdf'));
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Share a generated file via the platform share sheet.
  Future<void> shareFile(File file, {String? subject, String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject ?? file.uri.pathSegments.last,
        text: text ?? '',
      );
    } catch (e) {
      debugPrint('share error: $e');
    }
  }
}
