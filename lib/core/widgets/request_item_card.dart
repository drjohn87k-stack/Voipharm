import 'package:flutter/material.dart';

/// A single line-item card shown inside the request builder.
///
/// Displays the item name, quantity, optional notes, and provides
/// edit / delete buttons plus an optional drag handle for reordering.
/// The card is RTL-aware: the layout automatically mirrors when the
/// ambient [Directionality] is RTL.
class RequestItemCard extends StatelessWidget {
  const RequestItemCard({
    super.key,
    required this.index,
    required this.itemName,
    required this.quantity,
    this.notes,
    this.onEdit,
    this.onDelete,
    this.onIncrement,
    this.onDecrement,
    this.onReorderUp,
    this.onReorderDown,
  });

  final int index;
  final String itemName;
  final int quantity;
  final String? notes;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onReorderUp;
  final VoidCallback? onReorderDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Index badge
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Name + notes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notes != null && notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notes!.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Quantity stepper
            _QtyStepper(
              quantity: quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),

            // Action buttons
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              color: cs.error,
              onPressed: onDelete,
            ),
            if (onReorderUp != null)
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                tooltip: 'Move up',
                visualDensity: VisualDensity.compact,
                onPressed: onReorderUp,
              ),
            if (onReorderDown != null)
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                tooltip: 'Move down',
                visualDensity: VisualDensity.compact,
                onPressed: onReorderDown,
              ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            onPressed: onDecrement,
          ),
          Text(
            '$quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSecondaryContainer,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
