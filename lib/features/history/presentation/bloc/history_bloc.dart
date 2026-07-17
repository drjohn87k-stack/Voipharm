import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../request/data/requests_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

export 'history_event.dart';
export 'history_state.dart';

/// BLoC for the history screen. Loads all saved requests grouped by date.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(const HistoryInitial()) {
    on<HistoryLoadStarted>(_onLoadStarted);
    on<HistoryRequestDeleted>(_onDeleted);
    on<HistoryRequestOpened>(_onOpened);
  }

  final RequestsRepository _repo = RequestsRepository.instance;

  Future<void> _onLoadStarted(
      HistoryLoadStarted event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoadInProgress());
    try {
      final requests = await _repo.allRequests();
      if (requests.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoadSuccess(requests));
      }
    } catch (e) {
      debugPrint('history load error: $e');
      emit(HistoryLoadFailure(e.toString()));
    }
  }

  Future<void> _onDeleted(
      HistoryRequestDeleted event, Emitter<HistoryState> emit) async {
    try {
      await _repo.deleteRequest(event.id);
      final requests = await _repo.allRequests();
      if (requests.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoadSuccess(requests));
      }
    } catch (e) {
      emit(HistoryLoadFailure(e.toString()));
    }
  }

  void _onOpened(HistoryRequestOpened event, Emitter<HistoryState> emit) {
    // The home screen listens and navigates; nothing to emit here.
  }
}
