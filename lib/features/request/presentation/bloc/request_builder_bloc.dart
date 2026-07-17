import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/requests_repository.dart';
import '../../domain/request_item_entity.dart';
import 'request_builder_event.dart';
import 'request_builder_state.dart';

export 'request_builder_event.dart';
export 'request_builder_state.dart';

/// BLoC for the request builder screen.
///
/// Holds the in-memory request (header + items) and handles all
/// add / edit / reorder / delete / save operations. The state is a
/// [RequestBuilderEditing] that mirrors a [RequestEntity] plus some
/// transient UI flags (isSaving, voice-qty capture, status message).
class RequestBuilderBloc
    extends Bloc<RequestBuilderEvent, RequestBuilderState> {
  RequestBuilderBloc() : super(const RequestBuilderInitial()) {
    on<RequestItemAdded>(_onItemAdded);
    on<RequestEntityItemAdded>(_onEntityItemAdded);
    on<RequestQuantityChanged>(_onQuantityChanged);
    on<RequestQuantityByNameSet>(_onQuantityByNameSet);
    on<RequestNotesChanged>(_onNotesChanged);
    on<RequestItemEdited>(_onItemEdited);
    on<RequestItemRemoved>(_onItemRemoved);
    on<RequestItemMovedUp>(_onMoveUp);
    on<RequestItemMovedDown>(_onMoveDown);
    on<RequestCleared>(_onCleared);
    on<RequestHeaderChanged>(_onHeaderChanged);
    on<RequestSaved>(_onSaved);
    on<RequestLoaded>(_onLoaded);
    on<RequestNewStarted>(_onNewStarted);
  }

  final RequestsRepository _repo = RequestsRepository.instance;

  RequestBuilderEditing _ensureEditing() {
    final s = state;
    if (s is RequestBuilderEditing) return s;
    return const RequestBuilderEditing();
  }

  void _onNewStarted(RequestNewStarted event, Emitter<RequestBuilderState> emit) {
    emit(RequestBuilderEditing(date: _today()));
  }

  String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _onItemAdded(RequestItemAdded event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    // If the item already exists, just bump the quantity.
    final existingIdx = s.items
        .indexWhere((i) => i.itemName.toLowerCase() == event.itemName.toLowerCase());
    if (existingIdx >= 0) {
      final items = List<RequestItemEntity>.from(s.items);
      items[existingIdx] =
          items[existingIdx].copyWith(quantity: items[existingIdx].quantity + event.quantity);
      emit(s.copyWith(items: items, statusMessage: '+1 ${event.itemName}', clearVoiceQty: true));
    } else {
      final items = List<RequestItemEntity>.from(s.items);
      items.add(RequestItemEntity(
        itemName: event.itemName,
        quantity: event.quantity,
        notes: event.notes,
        orderIndex: items.length,
      ));
      emit(s.copyWith(items: items, statusMessage: 'Added: ${event.itemName}', clearVoiceQty: true));
    }
  }

  void _onEntityItemAdded(RequestEntityItemAdded event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    final existingIdx = s.items
        .indexWhere((i) => i.itemName.toLowerCase() == event.item.itemName.toLowerCase());
    final items = List<RequestItemEntity>.from(s.items);
    if (existingIdx >= 0) {
      items[existingIdx] = items[existingIdx].copyWith(
          quantity: items[existingIdx].quantity + event.item.quantity);
    } else {
      items.add(event.item.copyWith(orderIndex: items.length));
    }
    emit(s.copyWith(items: items, statusMessage: 'Added: ${event.item.itemName}', clearVoiceQty: true));
  }

  void _onQuantityChanged(
      RequestQuantityChanged event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    if (event.index < 0 || event.index >= s.items.length) return;
    final items = List<RequestItemEntity>.from(s.items);
    items[event.index] =
        items[event.index].copyWith(quantity: event.quantity < 1 ? 1 : event.quantity);
    emit(s.copyWith(items: items, clearStatus: true));
  }

  void _onQuantityByNameSet(
      RequestQuantityByNameSet event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    final idx =
        s.items.indexWhere((i) => i.itemName.toLowerCase() == event.itemName.toLowerCase());
    if (idx < 0) return;
    final items = List<RequestItemEntity>.from(s.items);
    items[idx] = items[idx].copyWith(quantity: event.quantity < 1 ? 1 : event.quantity);
    emit(s.copyWith(items: items, isListeningQty: false, clearVoiceQty: true, statusMessage: 'Qty set: ${event.itemName} = ${event.quantity}'));
  }

  void _onNotesChanged(RequestNotesChanged event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    if (event.index < 0 || event.index >= s.items.length) return;
    final items = List<RequestItemEntity>.from(s.items);
    items[event.index] = items[event.index].copyWith(notes: event.notes);
    emit(s.copyWith(items: items, clearStatus: true));
  }

  void _onItemEdited(RequestItemEdited event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    if (event.index < 0 || event.index >= s.items.length) return;
    final items = List<RequestItemEntity>.from(s.items);
    items[event.index] = items[event.index].copyWith(
      itemName: event.itemName,
      quantity: event.quantity ?? items[event.index].quantity,
      notes: event.notes ?? items[event.index].notes,
    );
    emit(s.copyWith(items: items, clearStatus: true));
  }

  void _onItemRemoved(RequestItemRemoved event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    if (event.index < 0 || event.index >= s.items.length) return;
    final items = List<RequestItemEntity>.from(s.items)..removeAt(event.index);
    // re-index
    for (var i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(orderIndex: i);
    }
    emit(s.copyWith(items: items, statusMessage: 'Removed item', clearVoiceQty: true));
  }

  void _onMoveUp(RequestItemMovedUp event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    if (event.index <= 0 || event.index >= s.items.length) return;
    final items = List<RequestItemEntity>.from(s.items);
    final tmp = items[event.index - 1];
    items[event.index - 1] = items[event.index].copyWith(orderIndex: event.index - 1);
    items[event.index] = tmp.copyWith(orderIndex: event.index);
    emit(s.copyWith(items: items, clearStatus: true));
  }

  void _onMoveDown(RequestItemMovedDown event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    if (event.index < 0 || event.index >= s.items.length - 1) return;
    final items = List<RequestItemEntity>.from(s.items);
    final tmp = items[event.index + 1];
    items[event.index + 1] = items[event.index].copyWith(orderIndex: event.index + 1);
    items[event.index] = tmp.copyWith(orderIndex: event.index);
    emit(s.copyWith(items: items, clearStatus: true));
  }

  void _onCleared(RequestCleared event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    emit(s.copyWith(items: const [], statusMessage: 'Cleared', clearVoiceQty: true));
  }

  void _onHeaderChanged(RequestHeaderChanged event, Emitter<RequestBuilderState> emit) {
    final s = _ensureEditing();
    emit(s.copyWith(
      title: event.title,
      date: event.date,
      department: event.department,
      requester: event.requester,
      signature: event.signature,
      clearStatus: true,
    ));
  }

  Future<void> _onSaved(RequestSaved event, Emitter<RequestBuilderState> emit) async {
    final s = _ensureEditing();
    if (s.items.isEmpty) {
      emit(s.copyWith(statusMessage: 'Cannot save an empty request'));
      return;
    }
    emit(s.copyWith(isSaving: true, clearStatus: true));
    try {
      final entity = s.toEntity();
      final id = await _repo.saveRequest(entity);
      emit(s.copyWith(
        id: id,
        isSaving: false,
        lastSavedId: id,
        statusMessage: 'Saved ( #$id )',
      ));
    } catch (e) {
      debugPrint('save error: $e');
      emit(s.copyWith(isSaving: false, statusMessage: 'Save failed: $e'));
    }
  }

  void _onLoaded(RequestLoaded event, Emitter<RequestBuilderState> emit) {
    final r = event.request;
    emit(RequestBuilderEditing(
      id: r.id,
      title: r.title ?? '',
      date: r.date,
      department: r.department ?? '',
      requester: r.requester ?? '',
      signature: r.signature ?? '',
      items: r.items,
      statusMessage: 'Loaded request #${r.id}',
    ));
  }
}
