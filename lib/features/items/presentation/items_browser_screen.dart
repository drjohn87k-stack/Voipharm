import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/widgets/voice_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/medical_item.dart';
import 'bloc/items_bloc.dart';

/// Items browser screen: search (text + voice) and tap to add an item
/// to the current request. The selected item is returned via [onItemSelected].
class ItemsBrowserScreen extends StatefulWidget {
  const ItemsBrowserScreen({
    super.key,
    required this.onItemSelected,
  });

  /// Called when the user taps an item to add it to the request.
  final void Function(MedicalItem item) onItemSelected;

  @override
  State<ItemsBrowserScreen> createState() => _ItemsBrowserScreenState();
}

class _ItemsBrowserScreenState extends State<ItemsBrowserScreen> {
  final _searchController = TextEditingController();
  bool _voiceActive = false;

  @override
  void initState() {
    super.initState();
    context.read<ItemsBloc>().add(const ItemsLoadStarted());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = LocaleService.instance.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.itemsBrowser),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: l.searchItems,
                      hintText: l.typeItemNameOrSpeak,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<ItemsBloc>()
                                    .add(const ItemsSearchChanged(''));
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) {
                      context
                          .read<ItemsBloc>()
                          .add(ItemsSearchChanged(v));
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                VoiceButton(
                  isListening: _voiceActive,
                  onTap: () => _toggleVoice(isAr),
                ),
              ],
            ),
          ),
          // Voice result preview
          BlocBuilder<ItemsBloc, ItemsState>(
            buildWhen: (p, c) =>
                c is ItemsLoadSuccess &&
                (p is! ItemsLoadSuccess ||
                    p.isListening != c.isListening ||
                    p.lastWords != c.lastWords),
            builder: (context, state) {
              if (state is ItemsLoadSuccess &&
                  state.isListening &&
                  state.lastWords.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    color:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.mic),
                      title: Text(
                        '“${state.lastWords}”',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                      dense: true,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Results list (scrollable)
          Expanded(
            child: BlocBuilder<ItemsBloc, ItemsState>(
              builder: (context, state) {
                if (state is ItemsLoadInProgress ||
                    state is ItemsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ItemsLoadFailure) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    message: state.message,
                  );
                }
                if (state is ItemsLoadSuccess) {
                  if (state.items.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      message: l.noItemsFound,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                        bottom: 80, top: 4),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ListTile(
                        title: Text(item.itemName),
                        subtitle: item.category != null
                            ? Text(item.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall)
                            : null,
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () {
                          widget.onItemSelected(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${l.added}: ${item.itemName}'),
                              duration:
                                  const Duration(milliseconds: 800),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVoice(bool isAr) async {
    final bloc = context.read<ItemsBloc>();
    if (_voiceActive) {
      await bloc.stopVoiceSearch();
      setState(() => _voiceActive = false);
    } else {
      setState(() => _voiceActive = true);
      await bloc.startVoiceSearch(language: isAr ? 'ar' : 'en');
      // Auto-stop UI flag after a delay
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) setState(() => _voiceActive = false);
      });
    }
  }
}
