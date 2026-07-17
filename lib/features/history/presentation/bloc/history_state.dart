import 'package:equatable/equatable.dart';
import '../../../request/domain/request_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoadInProgress extends HistoryState {
  const HistoryLoadInProgress();
}

class HistoryLoadSuccess extends HistoryState {
  const HistoryLoadSuccess(this.requests);
  final List<RequestEntity> requests;

  /// Group requests by their date string (yyyy-MM-dd), newest first.
  Map<String, List<RequestEntity>> groupedByDate() {
    final map = <String, List<RequestEntity>>{};
    for (final r in requests) {
      final key = (r.date ?? r.createdAt ?? '').substring(0, 10);
      map.putIfAbsent(key, () => []).add(r);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, map[k]!)));
  }

  @override
  List<Object?> get props => [requests];
}

class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

class HistoryLoadFailure extends HistoryState {
  const HistoryLoadFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
