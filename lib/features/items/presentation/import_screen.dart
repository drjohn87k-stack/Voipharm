import 'package:flutter/material.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../items/data/import_service.dart';
import '../../items/data/items_repository.dart';

/// Import screen: lets the user pick a .docx / .txt / .csv / .xls file
/// and either merge it into the existing master list or replace it.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _busy = false;
  String? _message;
  int _parsedCount = 0;

  Future<void> _pickAndImport({required bool replace}) async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      // Request storage permission on Android
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'txt', 'csv', 'xls'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        setState(() {
          _busy = false;
          _message = l.noFileSelected;
        });
        return;
      }
      final path = result.files.single.path;
      if (path == null) {
        setState(() {
          _busy = false;
          _message = l.noFileSelected;
        });
        return;
      }

      final items = await ImportService.instance.parseFile(path);
      _parsedCount = items.length;
      if (items.isEmpty) {
        setState(() {
          _busy = false;
          _message = l.noItemsFoundInFile;
        });
        return;
      }

      int affected;
      if (replace) {
        await ItemsRepository.instance.replaceAll(items);
        affected = items.length;
      } else {
        affected = await ItemsRepository.instance.mergeMany(items);
      }

      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = replace
            ? '${l.replaced}: $affected / $_parsedCount ${l.items.toLowerCase()}'
            : '${l.merged}: $affected / $_parsedCount ${l.items.toLowerCase()}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = '${l.error}: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.importItems),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.file_upload_outlined,
                  size: 64, color: cs.primary),
              const SizedBox(height: 12),
              Text(
                l.importDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (_message != null) ...[
                Card(
                  color: _message!.startsWith(l.error) ||
                          _message!.startsWith(l.error)
                      ? cs.errorContainer
                      : cs.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _message!,
                      style: TextStyle(
                          color: _message!.startsWith(l.error)
                              ? cs.onErrorContainer
                              : cs.onPrimaryContainer),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_busy)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                FilledButton.icon(
                  onPressed: () => _pickAndImport(replace: false),
                  icon: const Icon(Icons.merge_type),
                  label: Text(l.mergeImport),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => _pickAndImport(replace: true),
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l.replaceImport),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(l.supportedFormats,
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(
                l.formatsList,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
