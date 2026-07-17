import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/items_repository.dart';
import '../../../../core/utils/fuzzy_matcher.dart';
import '../../../../core/services/speech_service.dart';
import 'items_event.dart';
import 'items_state.dart';

export 'items_event.dart';
export 'items_state.dart';

/// BLoC that manages the items browse/search screen.
///
/// It combines fast SQL LIKE search with client-side fuzzy matching so
/// that misspelled or partial names still return useful results. It also
/// wires the voice-search flow: when [ItemsVoiceSearch] fires it runs a
/// SQL search against the spoken phrase and, if nothing matches, falls
/// back to a fuzzy match over a larger candidate set.
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc() : super(const ItemsInitial()) {
    on<ItemsLoadStarted>(_onLoadStarted);
    on<ItemsSearchChanged>(_onSearchChanged);
    on<ItemsVoiceSearch>(_onVoiceSearch);
    on<ItemsItemSelected>(_onItemSelected);
    on<ItemsRefreshed>(_onRefreshed);
  }

  final ItemsRepository _repo = ItemsRepository.instance;
  final SpeechService _speech = SpeechService.instance;
  Timer? _debounce;

  Future<void> _onLoadStarted(
      ItemsLoadStarted event, Emitter<ItemsState> emit) async {
    emit(const ItemsLoadInProgress());
    try {
      await _repo.ensureSeeded();
      final items = await _repo.search('', limit: 80);
      final total = await _repo.count();
      emit(ItemsLoadSuccess(
        items: items,
        totalCount: total,
      ));
    } catch (e) {
      emit(ItemsLoadFailure(e.toString()));
    }
  }

  Future<void> _onSearchChanged(
      ItemsSearchChanged event, Emitter<ItemsState> emit) async {
    final current = state;
    if (current is! ItemsLoadSuccess) return;
    _debounce?.cancel();
    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      completer.complete();
    });
    await completer.future;
    try {
      final items = await _repo.search(event.query, limit: 80);
      emit(current.copyWith(items: items, query: event.query));
    } catch (e) {
      debugPrint('search error: $e');
    }
  }

  Future<void> _onVoiceSearch(
      ItemsVoiceSearch event, Emitter<ItemsState> emit) async {
    final current = state;
    if (current is! ItemsLoadSuccess) return;
    emit(current.copyWith(
      isListening: true,
      lastWords: event.spokenText,
    ));
    try {
      var items = await _repo.search(event.spokenText, limit: 80);
      // Fuzzy fallback: pull a bigger candidate set and re-rank.
      if (items.isEmpty && event.spokenText.trim().isNotEmpty) {
        final candidates = await _repo.search('', limit: 500);
        final ranked = FuzzyMatcher.sortByRelevance(event.spokenText,
            candidates.map((e) => e.itemName).toList());
        final topNames = ranked.take(30).toSet();
        items = candidates
            .where((m) => topNames.contains(m.itemName))
            .toList();
      }
      emit(current.copyWith(
        items: items,
        query: event.spokenText,
        isListening: false,
      ));
    } catch (e) {
      emit(current.copyWith(isListening: false));
    }
  }

  Future<void> _onItemSelected(
      ItemsItemSelected event, Emitter<ItemsState> emit) async {
    final current = state;
    if (current is! ItemsLoadSuccess) return;
    emit(current.copyWith(selectedItem: event.item));
  }

  Future<void> _onRefreshed(
      ItemsRefreshed event, Emitter<ItemsState> emit) async {
    final current = state;
    if (current is! ItemsLoadSuccess) return;
    final items = await _repo.search(current.query, limit: 80);
    final total = await _repo.count();
    emit(current.copyWith(items: items, totalCount: total));
  }

  /// Convenience used by the UI to start voice listening.
  Future<void> startVoiceSearch({String language = 'en'}) async {
    add(const ItemsVoiceSearch(''));
    await _speech.startListening(
      language: language,
      onResult: (words) => add(ItemsVoiceSearch(words)),
    );
  }

  Future<void> stopVoiceSearch() async {
    await _speech.stopListening();
    final current = state;
    if (current is ItemsLoadSuccess) {
      add(ItemsVoiceSearch(current.lastWords));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
