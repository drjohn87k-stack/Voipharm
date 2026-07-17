import 'package:equatable/equatable.dart';
import '../../../request/domain/request_entity.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoadStarted extends HistoryEvent {
  const HistoryLoadStarted();
}

class HistoryRequestDeleted extends HistoryEvent {
  const HistoryRequestDeleted(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class HistoryRequestOpened extends HistoryEvent {
  const HistoryRequestOpened(this.request);
  final RequestEntity request;
  @override
  List<Object?> get props => [request];
}
