import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../domain/request_item_entity.dart';
import '../bloc/request_builder_bloc.dart';

/// Dialog to edit an item's name / quantity / notes, with voice
/// quantity capture.
class EditItemDialog extends StatefulWidget {
  const EditItemDialog({
    super.key,
    required this.item,
    required this.index,
  });
  final RequestItemEntity item;
  final int index;

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _notesCtrl;
  bool _listeningQty = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.itemName);
    _qtyCtrl = TextEditingController(text: '${widget.item.quantity}');
    _notesCtrl = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _voiceQty() async {
    final isAr = LocaleService.instance.isArabic;
    setState(() => _listeningQty = true);
    final value = await SpeechService.instance
        .listenForNumber(language: isAr ? 'ar' : 'en');
    if (!mounted) return;
    setState(() => _listeningQty = false);
    if (value != null) {
      _qtyCtrl.text = '$value';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No number recognized.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.editItem),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l.itemName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.quantity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _listeningQty ? null : _voiceQty,
                  icon: Icon(_listeningQty ? Icons.mic : Icons.mic_none),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l.notes,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () {
            final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
            context.read<RequestBuilderBloc>().add(
                  RequestItemEdited(
                    widget.index,
                    _nameCtrl.text.trim(),
                    quantity: qty < 1 ? 1 : qty,
                    notes: _notesCtrl.text.trim(),
                  ),
                );
            Navigator.of(context).pop();
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
