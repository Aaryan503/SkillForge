import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/checkpoint_model.dart';
import 'user_provider.dart';

// Checkpoint state class
class CheckpointState {
  final List<Checkpoint> checkpoints;
  final bool isLoading;
  final String? error;

  CheckpointState({
    this.checkpoints = const [],
    this.isLoading = false,
    this.error,
  });

  CheckpointState copyWith({
    List<Checkpoint>? checkpoints,
    bool? isLoading,
    String? error,
  }) {
    return CheckpointState(
      checkpoints: checkpoints ?? this.checkpoints,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Checkpoint provider
class CheckpointNotifier extends StateNotifier<CheckpointState> {
  CheckpointNotifier() : super(CheckpointState());

  final SupabaseClient _supabase = Supabase.instance.client;

  // Load checkpoints for a specific challenge
  Future<void> loadCheckpoints(String challengeId) async {
    if (challengeId.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _supabase
          .from('checkpoint_table')
          .select('*')
          .eq('challenge_id', challengeId)
          .order('index', ascending: true);

      final List<Checkpoint> checkpoints = (response as List)
          .map((json) => Checkpoint(
                index: json['index'] ?? 1,
                title: json['title'] ?? '',
                description: json['description'] ?? '',
                challenge_id: json['challenge_id'] ?? '',
                completedBy: _parseCompletedBy(json['completed_by']),
              ))
          .toList();

      state = state.copyWith(
        checkpoints: checkpoints,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load checkpoints: $e',
      );
    }
  }

  // Update checkpoint completion for a user
  Future<void> updateCheckpointCompletion(
      String challengeId, int index, String userId, bool markCompleted) async {
    try {
      // Fetch the checkpoint
      final checkpoint = state.checkpoints.firstWhere(
        (c) => c.challenge_id == challengeId && c.index == index,
        orElse: () => throw Exception('Checkpoint not found'),
      );

      List<String> updatedCompletedBy = List<String>.from(checkpoint.completedBy);
      if (markCompleted) {
        if (!updatedCompletedBy.contains(userId)) {
          updatedCompletedBy.add(userId);
        }
      } else {
        updatedCompletedBy.remove(userId);
      }

      // Update in Supabase
      await _supabase
          .from('checkpoint_table')
          .update({'completed_by': updatedCompletedBy})
          .eq('challenge_id', challengeId)
          .eq('index', index);

      // Update local state
      final updatedCheckpoints = state.checkpoints.map((c) {
        if (c.challenge_id == challengeId && c.index == index) {
          return Checkpoint(
            index: c.index,
            title: c.title,
            description: c.description,
            challenge_id: c.challenge_id,
            completedBy: updatedCompletedBy,
          );
        }
        return c;
      }).toList();

      state = state.copyWith(checkpoints: updatedCheckpoints);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update checkpoint: $e',
      );
    }
  }

  // Clear checkpoints when switching challenges
  void clearCheckpoints() {
    state = CheckpointState();
  }

  // Get completion percentage for a user
  double getCompletionPercentage(String userId) {
    if (state.checkpoints.isEmpty) return 0.0;
    final completedCount = state.checkpoints.where((c) => c.completedBy.contains(userId)).length;
    return completedCount / state.checkpoints.length;
  }

  // Get next incomplete checkpoint for a user
  Checkpoint? getNextCheckpointForUser(String userId) {
    return state.checkpoints.cast<Checkpoint?>().firstWhere(
      (checkpoint) => checkpoint != null && !checkpoint.completedBy.contains(userId),
      orElse: () => null,
    );
  }

  List<String> _parseCompletedBy(dynamic completedByRaw) {
    if (completedByRaw == null) return [];
    if (completedByRaw is List) {
      // Defensive: convert all to string
      return completedByRaw.map((e) => e.toString()).toList();
    }
    // If it's a single value (int, bool, etc.), return as string in a list
    return [completedByRaw.toString()];
  }
}

// Provider instances
final checkpointProvider = StateNotifierProvider<CheckpointNotifier, CheckpointState>((ref) {
  return CheckpointNotifier();
});

// Provider for checkpoints of a specific challenge
final challengeCheckpointsProvider = Provider.family<List<Checkpoint>, String>((ref, challengeId) {
  final checkpointState = ref.watch(checkpointProvider);
  return checkpointState.checkpoints
      .where((checkpoint) => checkpoint.challenge_id == challengeId)
      .toList();
});

// Provider for completion percentage of a specific challenge for the current user
final challengeCompletionProvider = Provider.family<double, String>((ref, challengeId) {
  final checkpoints = ref.watch(challengeCheckpointsProvider(challengeId));
  final userId = ref.watch(userProvider).userId;
  if (checkpoints.isEmpty || userId == null) return 0.0;
  final completedCount = checkpoints.where((c) => c.completedBy.contains(userId)).length;
  return completedCount / checkpoints.length;
});