import 'package:flutter/material.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import '../../domain/request_entity.dart';
import '../../data/export_service.dart';

/// A bottom sheet that lets the user choose export format (Word / PDF)
/// and then share the generated file.
class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key, required this.request});
  final RequestEntity request;

  static Future<void> show(
      BuildContext context, RequestEntity request) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExportDialog(request: request),
    );
  }

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _busy = false;

  Future<void> _doExport(bool isPdf) async {
    setState(() => _busy = true);
    try {
      final file = isPdf
          ? await ExportService.instance.exportPdf(widget.request)
          : await ExportService.instance.exportDocx(widget.request);
      await ExportService.instance.shareFile(
        file,
        subject: widget.request.title ?? 'Medical Request',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l.exportRequest,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.request.totalItems} ${l.items} · ${widget.request.totalQuantity} ${l.units}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              FilledButton.icon(
                onPressed: () => _doExport(false),
                icon: const Icon(Icons.description_outlined),
                label: Text(l.exportToWord),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => _doExport(true),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l.exportToPdf),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
