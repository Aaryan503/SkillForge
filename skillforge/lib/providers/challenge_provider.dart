import 'package:riverpod/riverpod.dart';
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

  void _loadChallenges() {
    // setting up database is left
    final challenges = [
      Challenge(
        id: '1',
        title: '30 Days of Python',
        description: 'Master Python fundamentals with daily challenges. Perfect for beginners who want to build a strong foundation.',
        estimatedTime: '30 days',
        language: 'Python',
        createdBy: 'Alice Chen',
        participants: [],
        difficulty: ChallengeDifficulty.beginner,
        tags: ['Programming', 'Backend'],
      ),
      Challenge(
        id: '2',
        title: 'Flutter UI Bootcamp',
        description: 'Build beautiful mobile UIs with Flutter in just 10 days. Learn animations, responsive design and Material 3.',
        estimatedTime: '10 days',
        language: 'Dart',
        createdBy: 'Robert Kim',
        participants: [],
        difficulty: ChallengeDifficulty.intermediate,
        tags: ['Mobile', 'UI/UX'],
      ),
      Challenge(
        id: '3',
        title: 'JavaScript Mastery',
        description: 'Deep dive into JavaScript concepts including closures, promises, and async/await. Build real-world projects.',
        estimatedTime: '21 days',
        language: 'JavaScript',
        createdBy: 'Carol Rodriguez',
        participants: [],
        difficulty: ChallengeDifficulty.advanced,
        tags: ['Web', 'Frontend'],
      ),
      Challenge(
        id: '4',
        title: 'Data Science with Python',
        description: 'Learn data visualization, analysis and machine learning fundamentals with practical exercises.',
        estimatedTime: '45 days',
        language: 'Python',
        createdBy: 'Michael Zhang',
        participants: [],
        difficulty: ChallengeDifficulty.intermediate,
        tags: ['Data', 'AI/ML'],
      ),
    ];

    final activeChallenge = [
      Challenge(
        id: '2',
        title: 'Flutter UI Bootcamp',
        description: 'Build beautiful mobile UIs with Flutter in just 10 days.',
        estimatedTime: '10 days',
        language: 'Dart',
        createdBy: 'Robert Kim',
        participants: [],
        difficulty: ChallengeDifficulty.intermediate,
        tags: ['Mobile', 'UI/UX'],
      ),
    ];

      state = state.copyWith(
        allChallenges: challenges,
        activeChallenges: activeChallenge,
        isLoading: false,
      );
  }

  // void joinChallenge(String challengeId) {
  //   final challenge = state.allChallenges.firstWhere((c) => c.id == challengeId);
  //   final updatedChallenge = Challenge(
  //     id: challenge.id,
  //     title: challenge.title,
  //     description: challenge.description,
  //     estimatedTime: challenge.estimatedTime,
  //     language: challenge.language,
  //     createdBy: challenge.createdBy,
  //     participants: challenge.participants,
  //     coverImage: challenge.coverImage,
  //     difficulty: challenge.difficulty,
  //     tags: challenge.tags,
  //     progress: 0.0,
  //     daysCompleted: 0,
  //   );

  //   state = state.copyWith(
  //     activeChallenges: [...state.activeChallenges, updatedChallenge],
  //   );
  // }

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