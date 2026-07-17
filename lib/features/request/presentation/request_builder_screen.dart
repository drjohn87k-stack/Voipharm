import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import 'package:medical_request_app/features/items/presentation/items_browser_screen.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/widgets/request_item_card.dart';
import '../../../core/widgets/voice_button.dart';
import '../../../core/widgets/empty_state.dart';
import 'bloc/request_builder_bloc.dart';
import 'widgets/edit_item_dialog.dart';
import 'widgets/export_dialog.dart';

/// The main Request Builder screen.
///
/// Features:
///  - Header fields (title, date, department, requester, signature)
///  - Scrollable list of added items (each item is fully visible; the
///    list is in an Expanded widget so it never hides behind the bottom
///    action bar).
///  - Voice add: speak an item name → it's added to the list.
///  - Voice quantity: speak a number for a specific item.
///  - Edit / delete / reorder each item.
///  - Save the request and export to Word / PDF.
class RequestBuilderScreen extends StatefulWidget {
  const RequestBuilderScreen({super.key});

  @override
  State<RequestBuilderScreen> createState() => _RequestBuilderScreenState();
}

class _RequestBuilderScreenState extends State<RequestBuilderScreen> {
  bool _voiceAddActive = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start a fresh editing session if none yet.
    final s = context.read<RequestBuilderBloc>().state;
    if (s is RequestBuilderInitial) {
      context.read<RequestBuilderBloc>().add(const RequestNewStarted());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = LocaleService.instance.isArabic;

    return BlocConsumer<RequestBuilderBloc, RequestBuilderState>(
      listenWhen: (p, c) =>
          c is RequestBuilderEditing &&
          c.items.length >
              (p is RequestBuilderEditing ? p.items.length : 0),
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        final editing =
            state is RequestBuilderEditing ? state : const RequestBuilderEditing();

        return Scaffold(
          appBar: AppBar(
            title: Text(editing.title.isEmpty
                ? l.requestBuilder
                : editing.title),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: l.clear,
                icon: const Icon(Icons.clear_all),
                onPressed: editing.items.isEmpty
                    ? null
                    : () => _confirmClear(context, l),
              ),
            ],
          ),
          body: SafeArea(
            // Column with an Expanded list so items never go behind
            // the bottom action bar.
            child: Column(
              children: [
                // Header summary card
                _HeaderSummary(editing: editing),
                // Voice-add bar
                _VoiceAddBar(
                  active: _voiceAddActive,
                  lastWords: editing.statusMessage ?? '',
                  onToggle: () => _toggleVoiceAdd(isAr),
                  isArabic: isAr,
                ),
                // Scrollable item list
                Expanded(
                  child: editing.items.isEmpty
                      ? EmptyState(
                          icon: Icons.add_shopping_cart_outlined,
                          message: l.noItemsAddedYet,
                          actionLabel: l.addByVoice,
                          onAction: () => _toggleVoiceAdd(isAr),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              top: 4, bottom: 96),
                          itemCount: editing.items.length,
                          itemBuilder: (context, index) {
                            final item = editing.items[index];
                            return RequestItemCard(
                              index: index,
                              itemName: item.itemName,
                              quantity: item.quantity,
                              notes: item.notes,
                              onIncrement: () => context
                                  .read<RequestBuilderBloc>()
                                  .add(RequestQuantityChanged(
                                      index, item.quantity + 1)),
                              onDecrement: () => context
                                  .read<RequestBuilderBloc>()
                                  .add(RequestQuantityChanged(
                                      index,
                                      item.quantity > 1
                                          ? item.quantity - 1
                                          : 1)),
                              onEdit: () => showDialog(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                  value: context
                                      .read<RequestBuilderBloc>(),
                                  child: EditItemDialog(
                                    item: item,
                                    index: index,
                                  ),
                                ),
                              ),
                              onDelete: () => context
                                  .read<RequestBuilderBloc>()
                                  .add(RequestItemRemoved(index)),
                              onReorderUp: index > 0
                                  ? () => context
                                      .read<RequestBuilderBloc>()
                                      .add(RequestItemMovedUp(index))
                                  : null,
                              onReorderDown: index <
                                      editing.items.length - 1
                                  ? () => context
                                      .read<RequestBuilderBloc>()
                                      .add(RequestItemMovedDown(index))
                                  : null,
                            );
                          },
                        ),
                ),
                // Bottom action bar (fixed, items never hide behind it)
                _BottomActionBar(
                  itemCount: editing.totalItems,
                  totalQty: editing.totalQuantity,
                  onSave: () => _save(context, l),
                  onExport: editing.items.isEmpty
                      ? null
                      : () => ExportDialog.show(
                          context, editing.toEntity()),
                  onAddItem: () => _openItemsBrowser(context),
                  onHeader: () => _openHeaderEditor(context, editing, l),
                  saving: editing.isSaving,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleVoiceAdd(bool isAr) async {
    final bloc = context.read<RequestBuilderBloc>();
    if (_voiceAddActive) {
      await SpeechService.instance.stopListening();
      setState(() => _voiceAddActive = false);
    } else {
      setState(() => _voiceAddActive = true);
      String captured = '';
      await SpeechService.instance.startListening(
        language: isAr ? 'ar' : 'en',
        onResult: (words) {
          captured = words;
          // Live-add: when we get a final-ish result, add the item.
          if (words.trim().isNotEmpty) {
            bloc.add(RequestItemAdded(words.trim()));
          }
        },
      );
      // Stop after 8 seconds
      Future.delayed(const Duration(seconds: 8), () async {
        if (mounted) {
          await SpeechService.instance.stopListening();
          setState(() => _voiceAddActive = false);
          if (captured.trim().isNotEmpty) {
            _scrollToBottom();
          }
        }
      });
    }
  }

  void _openItemsBrowser(BuildContext context) async {
    final isAr = LocaleService.instance.isArabic;
    // Navigate to items browser; the selected item comes back.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ItemsBrowserRoute(
          isArabic: isAr,
          onSelected: (name) {
            context.read<RequestBuilderBloc>().add(
                  RequestItemAdded(name),
                );
          },
        ),
        fullscreenDialog: false,
      ),
    );
  }

  void _openHeaderEditor(
      BuildContext context, dynamic editing, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HeaderEditorSheet(editing: editing as dynamic),
    );
  }

  void _save(BuildContext context, AppLocalizations l) {
    context.read<RequestBuilderBloc>().add(const RequestSaved());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.requestSaved)),
    );
  }

  void _confirmClear(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.clear),
        content: Text(l.clearAllItemsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<RequestBuilderBloc>()
                  .add(const RequestCleared());
              Navigator.of(context).pop();
            },
            child: Text(l.clear),
          ),
        ],
      ),
    );
  }
}

// ---------- Header summary ----------
class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.editing});
  final dynamic editing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.request_quote_outlined, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((editing.title as String?)?.isNotEmpty ?? false)
                  Text(editing.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${editing.date ?? l.date}: ${editing.date ?? '—'}'
                  '   ${editing.department ?? ''}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '${editing.totalItems} ${l.items}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

// ---------- Voice add bar ----------
class _VoiceAddBar extends StatelessWidget {
  const _VoiceAddBar({
    required this.active,
    required this.lastWords,
    required this.onToggle,
    required this.isArabic,
  });
  final bool active;
  final String lastWords;
  final VoidCallback onToggle;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              active
                  ? (isArabic ? 'استمع... تحدث اسم الدواء' : 'Listening… speak an item name')
                  : l.addByVoiceHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          VoiceButton(isListening: active, onTap: onToggle),
        ],
      ),
    );
  }
}

// ---------- Bottom action bar ----------
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.itemCount,
    required this.totalQty,
    required this.onSave,
    required this.onExport,
    required this.onAddItem,
    required this.onHeader,
    required this.saving,
  });
  final int itemCount;
  final int totalQty;
  final VoidCallback onSave;
  final VoidCallback? onExport;
  final VoidCallback onAddItem;
  final VoidCallback onHeader;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: l.requestDetails,
              icon: const Icon(Icons.edit_note),
              onPressed: onHeader,
            ),
            IconButton(
              tooltip: l.addByVoice,
              icon: const Icon(Icons.mic),
              onPressed: onAddItem,
            ),
            const Spacer(),
            Text('$itemCount ${l.items} · $totalQty',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onExport,
              icon: const Icon(Icons.ios_share),
              label: Text(l.export),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Header editor sheet ----------
class _HeaderEditorSheet extends StatefulWidget {
  const _HeaderEditorSheet({required this.editing});
  final dynamic editing;

  @override
  State<_HeaderEditorSheet> createState() => _HeaderEditorSheetState();
}

class _HeaderEditorSheetState extends State<_HeaderEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _date;
  late final TextEditingController _dept;
  late final TextEditingController _requester;
  late final TextEditingController _signature;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e.title ?? '');
    _date = TextEditingController(text: e.date ?? '');
    _dept = TextEditingController(text: e.department ?? '');
    _requester = TextEditingController(text: e.requester ?? '');
    _signature = TextEditingController(text: e.signature ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _dept.dispose();
    _requester.dispose();
    _signature.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.requestDetails,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
                controller: _title,
                decoration: InputDecoration(
                    labelText: l.title, border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: _date,
                decoration: InputDecoration(
                    labelText: l.date, border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: _dept,
                decoration: InputDecoration(
                    labelText: l.department,
                    border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: _requester,
                decoration: InputDecoration(
                    labelText: l.requester,
                    border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: _signature,
                decoration: InputDecoration(
                    labelText: l.signature,
                    border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<RequestBuilderBloc>().add(RequestHeaderChanged(
                      title: _title.text.trim(),
                      date: _date.text.trim(),
                      department: _dept.text.trim(),
                      requester: _requester.text.trim(),
                      signature: _signature.text.trim(),
                    ));
                Navigator.of(context).pop();
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Lightweight route that hosts the items browser ----------

class _ItemsBrowserRoute extends StatelessWidget {
  const _ItemsBrowserRoute({
    required this.isArabic,
    required this.onSelected,
  });
  final bool isArabic;
  final void Function(String name) onSelected;

  @override
  Widget build(BuildContext context) {
    return ItemsBrowserScreen(
      onItemSelected: (item) => onSelected(item.itemName),
    );
  }
}
