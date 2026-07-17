import 'package:equatable/equatable.dart';
import '../../domain/request_entity.dart';
import '../../domain/request_item_entity.dart';

abstract class RequestBuilderState extends Equatable {
  const RequestBuilderState();
  @override
  List<Object?> get props => [];
}

class RequestBuilderInitial extends RequestBuilderState {
  const RequestBuilderInitial();
}

class RequestBuilderEditing extends RequestBuilderState {
  const RequestBuilderEditing({
    this.id,
    this.title = '',
    this.date,
    this.department = '',
    this.requester = '',
    this.signature = '',
    this.items = const [],
    this.isSaving = false,
    this.lastSavedId,
    this.statusMessage,
    this.voiceQtyForItem,
    this.isListeningQty = false,
  });

  final int? id;
  final String title;
  final String? date;
  final String department;
  final String requester;
  final String signature;
  final List<RequestItemEntity> items;
  final bool isSaving;
  final int? lastSavedId;
  final String? statusMessage;
  final String? voiceQtyForItem;
  final bool isListeningQty;

  int get totalItems => items.length;
  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);
  bool get isEmpty => items.isEmpty;

  RequestEntity toEntity() => RequestEntity(
        id: id,
        title: title.isEmpty ? null : title,
        date: date,
        department: department.isEmpty ? null : department,
        requester: requester.isEmpty ? null : requester,
        signature: signature.isEmpty ? null : signature,
        status: 'draft',
        items: items,
      );

  RequestBuilderEditing copyWith({
    int? id,
    String? title,
    String? date,
    String? department,
    String? requester,
    String? signature,
    List<RequestItemEntity>? items,
    bool? isSaving,
    int? lastSavedId,
    String? statusMessage,
    String? voiceQtyForItem,
    bool? isListeningQty,
    bool clearVoiceQty = false,
    bool clearStatus = false,
  }) =>
      RequestBuilderEditing(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        department: department ?? this.department,
        requester: requester ?? this.requester,
        signature: signature ?? this.signature,
        items: items ?? this.items,
        isSaving: isSaving ?? this.isSaving,
        lastSavedId: lastSavedId ?? this.lastSavedId,
        statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
        voiceQtyForItem: clearVoiceQty ? null : (voiceQtyForItem ?? this.voiceQtyForItem),
        isListeningQty: isListeningQty ?? this.isListeningQty,
      );

  @override
  List<Object?> get props => [
        id, title, date, department, requester, signature, items,
        isSaving, lastSavedId, statusMessage, voiceQtyForItem, isListeningQty,
      ];
}

class RequestBuilderSaved extends RequestBuilderState {
  const RequestBuilderSaved(this.requestId);
  final int requestId;
  @override
  List<Object?> get props => [requestId];
}

class RequestBuilderError extends RequestBuilderState {
  const RequestBuilderError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
