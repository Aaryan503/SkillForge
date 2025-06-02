import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/widgets/details_widgets/challenge_header_widget.dart';
import 'package:skillforge/widgets/details_widgets/challenge_info_widget.dart';
import 'package:skillforge/widgets/details_widgets/challenge_tab_bar_widget.dart';
import 'package:skillforge/widgets/details_widgets/challenge_tab_content_widget.dart';
import '../models/challenge_model.dart';
import '../providers/checkpoint_provider.dart';
import '../providers/user_provider.dart';
import '../providers/challenge_provider.dart';
import 'checkpoint_detail_screen.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({Key? key, required this.challenge}) : super(key: key);

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  bool _isJoined = false;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(checkpointProvider.notifier).loadCheckpoints(widget.challenge.id);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkpointState = ref.watch(checkpointProvider);
    final userId = ref.watch(userProvider).userId;
    final challengeState = ref.watch(challengeProvider);
    final challenge = challengeState.allChallenges.firstWhere(
      (c) => c.id == widget.challenge.id,
      orElse: () => widget.challenge,
    );
    final isParticipant = userId != null && challenge.participants.contains(userId);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.15,
                        child: Text(
                          (widget.challenge.language.isNotEmpty
                              ? widget.challenge.language.substring(0, 1).toUpperCase()
                              : "?"),
                          style: const TextStyle(
                            fontSize: 200,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Text(
                        widget.challenge.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChallengeHeaderWidget(
                    challenge: widget.challenge,
                    challengeColor: Theme.of(context).colorScheme.primary,
                    difficultyColor: _getDifficultyColor(),
                    difficultyText: _getDifficultyText(),
                  ),
                  const SizedBox(height: 24),
                  ChallengeInfoWidget(
                    challenge: widget.challenge,
                    challengeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  ChallengeTabBarWidget(
                    selectedTabIndex: _selectedTabIndex,
                    challengeColor: Theme.of(context).colorScheme.primary,
                    onTabSelected: (index) => setState(() => _selectedTabIndex = index),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ChallengeTabContentWidget(
                      selectedTabIndex: _selectedTabIndex,
                      challenge: widget.challenge,
                      challengeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isParticipant && userId != null)
                  ? () => _continueChallenge(checkpointState, userId)
                  : () async {
                      if (userId == null) return;
                      await ref.read(challengeProvider.notifier).joinChallenge(widget.challenge.id, userId);
                      setState(() => _isJoined = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have joined this challenge!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
              icon: Icon((isParticipant && userId != null) ? Icons.play_arrow : Icons.add),
              label: Text(_getButtonText(checkpointState, userId, isParticipant)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonText(CheckpointState checkpointState, String? userId, bool isParticipant) {
    if (!isParticipant) return "Join Challenge";
    if (userId == null) return "Continue Learning";
    final nextCheckpoint = ref.read(checkpointProvider.notifier).getNextCheckpointForUser(userId);
    if (nextCheckpoint != null) {
      return "Continue with ${nextCheckpoint.title}";
    }
    return "Continue Learning";
  }

  void _continueChallenge(CheckpointState checkpointState, String? userId) {
    if (userId == null) return;
    final nextCheckpoint = ref.read(checkpointProvider.notifier).getNextCheckpointForUser(userId);

    if (nextCheckpoint != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CheckpointDetailScreen(
            checkpoint: nextCheckpoint,
            challenge: widget.challenge,
            challengeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Congratulations! You\'ve completed all checkpoints!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getDifficultyColor() {
    switch (widget.challenge.difficulty) {
      case ChallengeDifficulty.beginner:
        return Colors.green;
      case ChallengeDifficulty.intermediate:
        return Colors.orange;
      case ChallengeDifficulty.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyText() {
    switch (widget.challenge.difficulty) {
      case ChallengeDifficulty.beginner:
        return 'Beginner';
      case ChallengeDifficulty.intermediate:
        return 'Intermediate';
      case ChallengeDifficulty.advanced:
        return 'Advanced';
    }
  }
}