import 'package:equatable/equatable.dart';
import '../../domain/medical_item.dart';

abstract class ItemsState extends Equatable {
  const ItemsState();
  @override
  List<Object?> get props => [];
}

class ItemsInitial extends ItemsState {
  const ItemsInitial();
}

class ItemsLoadInProgress extends ItemsState {
  const ItemsLoadInProgress();
}

class ItemsLoadSuccess extends ItemsState {
  const ItemsLoadSuccess({
    required this.items,
    required this.totalCount,
    this.query = '',
    this.selectedItem,
    this.isListening = false,
    this.lastWords = '',
  });

  final List<MedicalItem> items;
  final int totalCount;
  final String query;
  final MedicalItem? selectedItem;
  final bool isListening;
  final String lastWords;

  ItemsLoadSuccess copyWith({
    List<MedicalItem>? items,
    int? totalCount,
    String? query,
    MedicalItem? selectedItem,
    bool? isListening,
    String? lastWords,
    bool clearSelected = false,
  }) =>
      ItemsLoadSuccess(
        items: items ?? this.items,
        totalCount: totalCount ?? this.totalCount,
        query: query ?? this.query,
        selectedItem:
            clearSelected ? null : (selectedItem ?? this.selectedItem),
        isListening: isListening ?? this.isListening,
        lastWords: lastWords ?? this.lastWords,
      );

  @override
  List<Object?> get props =>
      [items, totalCount, query, selectedItem, isListening, lastWords];
}

class ItemsLoadFailure extends ItemsState {
  const ItemsLoadFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
