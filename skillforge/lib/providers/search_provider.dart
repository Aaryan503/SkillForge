import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/models/challenge_model.dart';
import 'package:skillforge/providers/challenge_provider.dart';

class SearchState {
  final String query;
  final List<Challenge> results;
  final bool isSearching;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<Challenge>? results,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;

  SearchNotifier(this.ref) : super(const SearchState());

  void searchChallenges(String query) {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isSearching: true);
    final allChallenges = ref.read(challengeProvider).allChallenges;

    final results = allChallenges.where((challenge) {
      final searchTerm = query.toLowerCase();
      return challenge.title.toLowerCase().contains(searchTerm) ||
             challenge.description.toLowerCase().contains(searchTerm) ||
             challenge.language.toLowerCase().contains(searchTerm) ||
             challenge.createdBy.toLowerCase().contains(searchTerm) ||
             challenge.tags.any((tag) => tag.toLowerCase().contains(searchTerm));
    }).toList();

    state = state.copyWith(
      results: results,
      isSearching: false,
    );
  }

  void clearSearch() {
    state = const SearchState();
  }
}
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});