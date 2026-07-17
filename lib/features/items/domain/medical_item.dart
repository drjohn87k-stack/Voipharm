import 'package:equatable/equatable.dart';

/// A master medical item (from the seeded database).
class MedicalItem extends Equatable {
  const MedicalItem({
    this.id,
    required this.itemName,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String itemName;
  final String? category;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'itemName': itemName,
        'category': category,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory MedicalItem.fromMap(Map<String, dynamic> map) => MedicalItem(
        id: map['id'] as int?,
        itemName: map['itemName'] as String,
        category: map['category'] as String?,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
      );

  @override
  List<Object?> get props => [id, itemName, category, createdAt, updatedAt];
}
