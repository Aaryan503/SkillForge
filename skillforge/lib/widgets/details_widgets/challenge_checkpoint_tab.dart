import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/checkpoint_model.dart';
import 'package:skillforge/models/challenge_model.dart';
import '../../providers/checkpoint_provider.dart';
import '../../providers/user_provider.dart';

class ChallengeCheckpointTab extends ConsumerStatefulWidget {
  final Challenge challenge;
  final Color challengeColor;

  const ChallengeCheckpointTab({
    Key? key,
    required this.challenge,
    required this.challengeColor,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeCheckpointTab> createState() => _ChallengeCheckpointTabState();
}

class _ChallengeCheckpointTabState extends ConsumerState<ChallengeCheckpointTab> {
  @override
  void initState() {
    super.initState();
    // Load checkpoints when the tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkpointProvider.notifier).loadCheckpoints(widget.challenge.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkpointState = ref.watch(checkpointProvider);
    final challengeCheckpoints = ref.watch(challengeCheckpointsProvider(widget.challenge.id));
    final completionPercentage = ref.watch(challengeCompletionProvider(widget.challenge.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(completionPercentage),
        const SizedBox(height: 20),
        _buildContent(checkpointState, challengeCheckpoints),
      ],
    );
  }

  Widget _buildHeader(double completionPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Challenge Roadmap",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (completionPercentage > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.challengeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.challengeColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  "${(completionPercentage * 100).toInt()}% Complete",
                  style: TextStyle(
                    color: widget.challengeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Complete each checkpoint to master ${widget.challenge.language}",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        if (completionPercentage > 0) ...[
          const SizedBox(height: 12),
          _buildProgressBar(completionPercentage),
        ],
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progress",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                color: widget.challengeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(widget.challengeColor),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildContent(CheckpointState checkpointState, List<Checkpoint> checkpoints) {
    if (checkpointState.isLoading) {
      return _buildLoadingState();
    }

    if (checkpointState.error != null) {
      return _buildErrorState(checkpointState.error!);
    }

    if (checkpoints.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCheckpointList(checkpoints);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(widget.challengeColor),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading checkpoints...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to load checkpoints",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(checkpointProvider.notifier).loadCheckpoints(widget.challenge.id);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.challengeColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.playlist_add_check_outlined,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "No checkpoints available",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Checkpoints will appear here once they are added to this challenge.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointList(List<Checkpoint> checkpoints) {
    final userId = ref.read(userProvider).userId;
    final challenge = widget.challenge;
    final isParticipant = userId != null && challenge.participants.contains(userId);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: checkpoints.length,
      itemBuilder: (context, index) {
        final checkpoint = checkpoints[index];
        final isCompleted = userId != null && checkpoint.completedBy.contains(userId);
        final isLocked = _isCheckpointLocked(checkpoints, index, userId);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200]!,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: isCompleted
                ? Border.all(color: widget.challengeColor.withOpacity(0.3), width: 1)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildCheckpointIcon(checkpoint, isCompleted, isLocked),
            title: Text(
              checkpoint.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isLocked 
                    ? Colors.grey[400]
                    : isCompleted 
                        ? Colors.grey 
                        : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  checkpoint.description,
                  style: TextStyle(
                    color: isLocked 
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: widget.challengeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Completed",
                        style: TextStyle(
                          color: widget.challengeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: isParticipant
                ? _buildTrailingWidget(checkpoint, isCompleted, isLocked, userId)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildCheckpointIcon(Checkpoint checkpoint, bool isCompleted, bool isLocked) {
    if (isLocked) {
      return CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.lock_outline,
          color: Colors.grey[600],
          size: 18,
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: isCompleted
          ? widget.challengeColor
          : Colors.grey[300],
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white)
          : Text(
              '${checkpoint.index}',
              style: TextStyle(
                color: isCompleted ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget? _buildTrailingWidget(Checkpoint checkpoint, bool isCompleted, bool isLocked, String? userId) {
    if (isCompleted || isLocked) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          color: widget.challengeColor,
          onPressed: () => _startCheckpoint(checkpoint),
        ),
        IconButton(
          icon: const Icon(Icons.check_circle_outline),
          color: Colors.grey[400],
          onPressed: () => _markAsCompleted(checkpoint, userId),
          tooltip: "Mark as completed",
        ),
      ],
    );
  }

  bool _isCheckpointLocked(List<Checkpoint> checkpoints, int currentIndex, String? userId) {
    if (currentIndex == 0) return false;
    if (currentIndex > 0) {
      final previousCheckpoint = checkpoints[currentIndex - 1];
      return userId == null || !previousCheckpoint.completedBy.contains(userId);
    }
    return false;
  }

  void _startCheckpoint(Checkpoint checkpoint) {
    // TODO: Navigate to checkpoint content/lesson screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting "${checkpoint.title}"'),
        backgroundColor: widget.challengeColor,
      ),
    );
  }

  void _markAsCompleted(Checkpoint checkpoint, String? userId) {
    if (userId == null) return;
    ref.read(checkpointProvider.notifier).updateCheckpointCompletion(
      checkpoint.challenge_id,
      checkpoint.index,
      userId,
      true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkpoint "${checkpoint.title}" marked as completed!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            ref.read(checkpointProvider.notifier).updateCheckpointCompletion(
              checkpoint.challenge_id,
              checkpoint.index,
              userId,
              false,
            );
          },
        ),
      ),
    );
  }
}