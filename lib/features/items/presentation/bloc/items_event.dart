import 'package:equatable/equatable.dart';
import '../../domain/medical_item.dart';

abstract class ItemsEvent extends Equatable {
  const ItemsEvent();
  @override
  List<Object?> get props => [];
}

/// Load initial count + first page of items.
class ItemsLoadStarted extends ItemsEvent {
  const ItemsLoadStarted();
}

/// Search query changed (debounced by the bloc).
class ItemsSearchChanged extends ItemsEvent {
  const ItemsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

/// Voice search result arrived.
class ItemsVoiceSearch extends ItemsEvent {
  const ItemsVoiceSearch(this.spokenText);
  final String spokenText;
  @override
  List<Object?> get props => [spokenText];
}

/// An item was selected (e.g. tapped to add to request).
class ItemsItemSelected extends ItemsEvent {
  const ItemsItemSelected(this.item);
  final MedicalItem item;
  @override
  List<Object?> get props => [item];
}

/// Reload the list (after import).
class ItemsRefreshed extends ItemsEvent {
  const ItemsRefreshed();
}
