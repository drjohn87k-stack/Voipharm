import 'package:equatable/equatable.dart';
import 'request_item_entity.dart';

/// A request (header) with its line items.
class RequestEntity extends Equatable {
  const RequestEntity({
    this.id,
    this.title,
    this.date,
    this.department,
    this.requester,
    this.signature,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  final int? id;
  final String? title;
  final String? date;
  final String? department;
  final String? requester;
  final String? signature;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final List<RequestItemEntity> items;

  RequestEntity copyWith({
    int? id,
    String? title,
    String? date,
    String? department,
    String? requester,
    String? signature,
    String? status,
    String? createdAt,
    String? updatedAt,
    List<RequestItemEntity>? items,
  }) =>
      RequestEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        department: department ?? this.department,
        requester: requester ?? this.requester,
        signature: signature ?? this.signature,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        items: items ?? this.items,
      );

  bool get isEmpty => items.isEmpty;
  int get totalItems => items.length;
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toHeaderMap() => {
        if (id != null) 'id': id,
        'title': title,
        'date': date,
        'department': department,
        'requester': requester,
        'signature': signature,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  factory RequestEntity.fromMap(
    Map<String, dynamic> header, {
    List<RequestItemEntity> items = const [],
  }) =>
      RequestEntity(
        id: header['id'] as int?,
        title: header['title'] as String?,
        date: header['date'] as String?,
        department: header['department'] as String?,
        requester: header['requester'] as String?,
        signature: header['signature'] as String?,
        status: header['status'] as String? ?? 'draft',
        createdAt: header['createdAt'] as String?,
        updatedAt: header['updatedAt'] as String?,
        items: items,
      );

  @override
  List<Object?> get props =>
      [id, title, date, department, requester, signature, status, items];
}
