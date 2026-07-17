import 'package:equatable/equatable.dart';

/// A request line item belonging to a [RequestEntity].
class RequestItemEntity extends Equatable {
  const RequestItemEntity({
    this.id,
    this.requestId,
    this.itemId,
    required this.itemName,
    this.quantity = 1,
    this.notes,
    this.orderIndex = 0,
  });

  final int? id;
  final int? requestId;
  final int? itemId;
  final String itemName;
  final int quantity;
  final String? notes;
  final int orderIndex;

  RequestItemEntity copyWith({
    int? id,
    int? requestId,
    int? itemId,
    String? itemName,
    int? quantity,
    String? notes,
    int? orderIndex,
  }) =>
      RequestItemEntity(
        id: id ?? this.id,
        requestId: requestId ?? this.requestId,
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
        orderIndex: orderIndex ?? this.orderIndex,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (requestId != null) 'requestId': requestId,
        'itemId': itemId,
        'itemName': itemName,
        'quantity': quantity,
        'notes': notes,
        'orderIndex': orderIndex,
      };

  factory RequestItemEntity.fromMap(Map<String, dynamic> map) =>
      RequestItemEntity(
        id: map['id'] as int?,
        requestId: map['requestId'] as int?,
        itemId: map['itemId'] as int?,
        itemName: map['itemName'] as String,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        notes: map['notes'] as String?,
        orderIndex: (map['orderIndex'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props =>
      [id, requestId, itemId, itemName, quantity, notes, orderIndex];
}
