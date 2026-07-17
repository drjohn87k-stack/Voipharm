import 'package:equatable/equatable.dart';
import '../../domain/request_item_entity.dart';
import '../../domain/request_entity.dart';

abstract class RequestBuilderEvent extends Equatable {
  const RequestBuilderEvent();
  @override
  List<Object?> get props => [];
}

/// Add an item (by name) to the current request.
class RequestItemAdded extends RequestBuilderEvent {
  const RequestItemAdded(this.itemName, {this.quantity = 1, this.notes});
  final String itemName;
  final int quantity;
  final String? notes;
  @override
  List<Object?> get props => [itemName, quantity, notes];
}

/// Add a [RequestItemEntity] (e.g. from the items browser).
class RequestEntityItemAdded extends RequestBuilderEvent {
  const RequestEntityItemAdded(this.item);
  final RequestItemEntity item;
  @override
  List<Object?> get props => [item];
}

/// Update quantity of an item at [index].
class RequestQuantityChanged extends RequestBuilderEvent {
  const RequestQuantityChanged(this.index, this.quantity);
  final int index;
  final int quantity;
  @override
  List<Object?> get props => [index, quantity];
}

/// Set the quantity for an item by name (used after voice qty capture).
class RequestQuantityByNameSet extends RequestBuilderEvent {
  const RequestQuantityByNameSet(this.itemName, this.quantity);
  final String itemName;
  final int quantity;
  @override
  List<Object?> get props => [itemName, quantity];
}

/// Update notes for an item at [index].
class RequestNotesChanged extends RequestBuilderEvent {
  const RequestNotesChanged(this.index, this.notes);
  final int index;
  final String notes;
  @override
  List<Object?> get props => [index, notes];
}

/// Edit a whole item at [index].
class RequestItemEdited extends RequestBuilderEvent {
  const RequestItemEdited(this.index, this.itemName,
      {this.quantity, this.notes});
  final int index;
  final String itemName;
  final int? quantity;
  final String? notes;
  @override
  List<Object?> get props => [index, itemName, quantity, notes];
}

/// Remove an item at [index].
class RequestItemRemoved extends RequestBuilderEvent {
  const RequestItemRemoved(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

/// Move an item up in the order.
class RequestItemMovedUp extends RequestBuilderEvent {
  const RequestItemMovedUp(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

/// Move an item down in the order.
class RequestItemMovedDown extends RequestBuilderEvent {
  const RequestItemMovedDown(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

/// Clear all items.
class RequestCleared extends RequestBuilderEvent {
  const RequestCleared();
}

/// Update header fields (title, date, department, requester, signature).
class RequestHeaderChanged extends RequestBuilderEvent {
  const RequestHeaderChanged({
    this.title,
    this.date,
    this.department,
    this.requester,
    this.signature,
  });
  final String? title;
  final String? date;
  final String? department;
  final String? requester;
  final String? signature;
  @override
  List<Object?> get props =>
      [title, date, department, requester, signature];
}

/// Save the current request to the database.
class RequestSaved extends RequestBuilderEvent {
  const RequestSaved();
}

/// Load an existing request (for editing).
class RequestLoaded extends RequestBuilderEvent {
  const RequestLoaded(this.request);
  final RequestEntity request;
  @override
  List<Object?> get props => [request];
}

/// Start a new empty request.
class RequestNewStarted extends RequestBuilderEvent {
  const RequestNewStarted();
}
