import 'package:riverpod/riverpod.dart';
import 'package:skillforge/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/challenge_model.dart';

class ChallengeState {
  final List<Challenge> allChallenges;
  final List<Challenge> activeChallenges;
  final bool isLoading;
  final String? error;

  const ChallengeState({
    required this.allChallenges,
    required this.activeChallenges,
    this.isLoading = false,
    this.error,
  });

  ChallengeState copyWith({
    List<Challenge>? allChallenges,
    List<Challenge>? activeChallenges,
    bool? isLoading,
    String? error,
  }) {
    return ChallengeState(
      allChallenges: allChallenges ?? this.allChallenges,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  ChallengeNotifier() : super(const ChallengeState(
    allChallenges: [],
    activeChallenges: [],
    isLoading: true,
  )) {
    _loadChallenges();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _loadChallenges() async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _supabase
          .from('challenge_table')
          .select()
          .order('created_at', ascending: false);

      final challenges = (response as List).map((challengeData) {
        return Challenge(
          id: challengeData['id'] as int,
          title: challengeData['title'] ?? '',
          description: challengeData['description'] ?? '',
          language: challengeData['language'] ?? '',
          createdBy: challengeData['creator'] ?? '',
          participants: List<String>.from(challengeData['participants'] ?? []),
          difficulty: ChallengeDifficulty.values.firstWhere(
            (d) => d.name == challengeData['difficulty'],
            orElse: () => ChallengeDifficulty.intermediate,
          ),
          tags: List<String>.from(challengeData['tags'] ?? []),
        );
      }).toList();

      final activeChallenges = challenges.where((challenge) {
        return challenge.participants.isNotEmpty;
      }).toList();

      state = state.copyWith(
        allChallenges: challenges,
        activeChallenges: activeChallenges,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load challenges: $e',
      );
    }
  }

  Future<Challenge> createChallenge(Challenge challenge) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _supabase
          .from('challenge_table')
          .insert({
            'title': challenge.title,
            'description': challenge.description,
            'language': challenge.language,
            'creator': challenge.createdBy,
            'participants': challenge.participants,
            'difficulty': challenge.difficulty.name,
            'tags': challenge.tags,
          })
          .select()
          .single();

      final createdChallenge = Challenge(
        id: response['id'] as int,
        title: response['title'],
        description: response['description'],
        language: response['language'],
        createdBy: response['creator'],
        participants: List<String>.from(response['participants'] ?? []),
        difficulty: ChallengeDifficulty.values.firstWhere(
          (d) => d.name == response['difficulty'],
          orElse: () => ChallengeDifficulty.intermediate,
        ),
        tags: List<String>.from(response['tags'] ?? []),
      );

      final updatedAllChallenges = [...state.allChallenges, createdChallenge];
      final updatedActiveChallenges = [...state.activeChallenges, createdChallenge];

      state = state.copyWith(
        allChallenges: updatedAllChallenges,
        activeChallenges: updatedActiveChallenges,
        isLoading: false,
      );

      return createdChallenge;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create challenge: $e',
      );
      rethrow;
    }
  }

  Future<void> joinChallenge(int challengeId, String userId) async {
    try {
      final challenge = state.allChallenges.firstWhere((c) => c.id == challengeId);
      if (challenge.participants.contains(userId)) return;

      final updatedParticipants = [...challenge.participants, userId];

      await _supabase
          .from('challenge_table')
          .update({'participants': updatedParticipants})
          .eq('id', challengeId);

      final updatedChallenge = Challenge(
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        language: challenge.language,
        createdBy: challenge.createdBy,
        participants: updatedParticipants,
        difficulty: challenge.difficulty,
        tags: challenge.tags,
      );

      final updatedAllChallenges = state.allChallenges.map((c) =>
        c.id == challengeId ? updatedChallenge : c
      ).toList();

      final updatedActiveChallenges = [
        ...state.activeChallenges.where((c) => c.id != challengeId),
        updatedChallenge
      ];

      state = state.copyWith(
        allChallenges: updatedAllChallenges,
        activeChallenges: updatedActiveChallenges,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to join challenge: $e',
      );
    }
  }

  Future<void> refreshChallenges() async {
    await _loadChallenges();
  }

  Future<void> loadActiveChallengesForUser(String userId) async {
    try {
      final activeChallenges = state.allChallenges.where((challenge) {
        return challenge.participants.contains(userId);
      }).toList();

      state = state.copyWith(activeChallenges: activeChallenges);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load active challenges: $e',
      );
    }
  }

  List<Challenge> get popularChallenges => 
      state.allChallenges.where((c) => c.participants.length > 200).toList();

  List<Challenge> get newChallenges => 
      state.allChallenges.take(2).toList();
}

final challengeProvider = StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  return ChallengeNotifier();
});

final popularChallengesProvider = Provider<List<Challenge>>((ref) {
  final challengeState = ref.watch(challengeProvider);
  return challengeState.allChallenges.where((c) => c.participants.length > 200).toList();
});

final newChallengesProvider = Provider<List<Challenge>>((ref) {
  final challengeState = ref.watch(challengeProvider);
  return challengeState.allChallenges.take(2).toList();
});

final userActiveChallengesProvider = Provider<List<Challenge>>((ref) {
  final challengeState = ref.watch(challengeProvider);
  final user = ref.watch(userProvider);
  
  if (user.isAuthenticated && user.userId != null) {
    return challengeState.allChallenges.where((challenge) {
      return challenge.participants.contains(user.userId);
    }).toList();
  }
  
  return [];
});