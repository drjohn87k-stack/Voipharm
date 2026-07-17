import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import '../../../core/widgets/empty_state.dart';
import '../../request/domain/request_entity.dart';
import 'bloc/history_bloc.dart';

/// History screen: lists saved requests grouped by date.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.onOpenRequest,
  });

  /// Called when the user opens a saved request for editing.
  final void Function(RequestEntity request) onOpenRequest;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryLoadStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.history),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l.refresh,
            onPressed: () => context
                .read<HistoryBloc>()
                .add(const HistoryLoadStarted()),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoadInProgress ||
              state is HistoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryEmpty) {
            return EmptyState(
              icon: Icons.history_outlined,
              message: l.noSavedRequests,
            );
          }
          if (state is HistoryLoadFailure) {
            return EmptyState(
                icon: Icons.error_outline, message: state.message);
          }
          if (state is HistoryLoadSuccess) {
            final grouped = state.groupedByDate();
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: grouped.length,
              itemBuilder: (context, idx) {
                final date = grouped.keys.elementAt(idx);
                final reqs = grouped[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        date.isEmpty ? l.undated : date,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ...reqs.map((r) => _RequestTile(
                          request: r,
                          onOpen: () => widget.onOpenRequest(r),
                          onDelete: () => _confirmDelete(context, r, l),
                        )),
                  ],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, RequestEntity r, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.delete),
        content: Text(l.deleteRequestConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              context
                  .read<HistoryBloc>()
                  .add(HistoryRequestDeleted(r.id!));
              Navigator.of(context).pop();
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.onOpen,
    required this.onDelete,
  });
  final RequestEntity request;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.request_quote_outlined),
        title: Text(
          request.title?.isNotEmpty == true
              ? request.title!
              : '${l.request} #${request.id}',
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${request.totalItems} ${l.items} · ${request.totalQuantity} ${l.units}'
          '${request.department != null ? ' · ${request.department}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onOpen,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: theme.colorScheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}
