import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/challenge_model.dart';

class UserProgressState {
  final List<Challenge> completedChallenges;
  final List<Challenge> activeChallenges;
  final List<Challenge> createdChallenges;
  final bool isLoading;
  final String? error;
  final String? lastLoadedUserId;

  const UserProgressState({
    this.completedChallenges = const [],
    this.activeChallenges = const [],
    this.createdChallenges = const [],
    this.isLoading = false,
    this.error,
    this.lastLoadedUserId,
  });

  UserProgressState copyWith({
    List<Challenge>? completedChallenges,
    List<Challenge>? activeChallenges,
    List<Challenge>? createdChallenges,
    bool? isLoading,
    String? error,
    String? lastLoadedUserId,
  }) {
    return UserProgressState(
      completedChallenges: completedChallenges ?? this.completedChallenges,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      createdChallenges: createdChallenges ?? this.createdChallenges,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastLoadedUserId: lastLoadedUserId ?? this.lastLoadedUserId,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  UserProgressNotifier() : super(const UserProgressState());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loadUserProgress(String userId, List<Challenge> allChallenges) async {
    if (userId.isEmpty) return;

    if (state.lastLoadedUserId == userId && !state.isLoading && state.error == null) {
      return;
    }

    if (state.isLoading && state.lastLoadedUserId == userId) return;

    state = state.copyWith(isLoading: true, error: null, lastLoadedUserId: userId);

    try {
      final createdChallenges = allChallenges
          .where((challenge) => challenge.createdBy == userId)
          .toList();

      final participatedChallenges = allChallenges
          .where((challenge) => challenge.participants.contains(userId))
          .toList();

      List<Challenge> completedChallenges = [];
      List<Challenge> activeChallenges = [];

      for (final challenge in participatedChallenges) {
        try {
          final completion = await _getChallengeCompletion(challenge.id, userId);
          if (completion >= 1.0) {
            completedChallenges.add(challenge);
          } else {
            activeChallenges.add(challenge);
          }
        } catch (e) {
          activeChallenges.add(challenge);
        }
      }

      state = state.copyWith(
        completedChallenges: completedChallenges,
        activeChallenges: activeChallenges,
        createdChallenges: createdChallenges,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user progress: $e',
      );
    }
  }

  Future<double> _getChallengeCompletion(int challengeId, String userId) async {
    try {
      final response = await _supabase
          .from('checkpoint_table')
          .select('completed_by')
          .eq('challenge_id', challengeId.toString());

      if (response.isEmpty) return 0.0;

      final totalCheckpoints = response.length;
      final completedCheckpoints = response.where((checkpoint) {
        final completedBy = checkpoint['completed_by'] as List?;
        return completedBy?.contains(userId) ?? false;
      }).length;

      return completedCheckpoints / totalCheckpoints;
    } catch (e) {
      return 0.0;
    }
  }

  void clearProgress() {
    state = const UserProgressState();
  }

  void refreshForUser(String userId, List<Challenge> allChallenges) {
    state = state.copyWith(lastLoadedUserId: null);
    loadUserProgress(userId, allChallenges);
  }
}

final userProgressProvider = StateNotifierProvider<UserProgressNotifier, UserProgressState>((ref) {
  return UserProgressNotifier();
});