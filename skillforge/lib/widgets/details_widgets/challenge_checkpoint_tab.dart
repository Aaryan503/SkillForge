import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/checkpoint_model.dart';
import 'package:skillforge/models/challenge_model.dart';
import '../../providers/checkpoint_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/checkpoint_detail_screen.dart'; 

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkpointProvider.notifier).loadCheckpoints(widget.challenge.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkpointState = ref.watch(checkpointProvider);
    final challengeCheckpoints = ref.watch(challengeCheckpointsProvider(widget.challenge.id));
    final completionPercentage = ref.watch(challengeCompletionProvider(widget.challenge.id));

    // Make the whole tab scrollable, including header and checkpoints
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(completionPercentage),
            const SizedBox(height: 20),
            _buildContent(checkpointState, challengeCheckpoints),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double completionPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
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
                    color: widget.challengeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.challengeColor.withValues(alpha: 0.3),
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
        ),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 20),
        Text(
          "Complete each checkpoint to master ${widget.challenge.language}",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        if (completionPercentage > 0) ...[
          const SizedBox(height: 16),
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

    if (checkpointState.error != null) {
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
              checkpointState.error!,
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

    if (checkpoints.isEmpty) {
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
                ? Border.all(color: widget.challengeColor.withValues(alpha: .3), width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CheckpointDetailScreen(
                      checkpoint: checkpoint,
                      challenge: widget.challenge,
                      challengeColor: widget.challengeColor,
                    ),
                  ),
                );
              },
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
                    if (isLocked) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Complete previous checkpoint",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: isParticipant && !isLocked
                    ? _buildTrailingWidget(checkpoint, isCompleted, isLocked, userId)
                    : _buildLockedTrailingWidget(isLocked),
              ),
            ),
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
    if (isLocked) {
      return null;
    }

    return IconButton(
      icon: Icon(
        isCompleted ? Icons.visibility_outlined : Icons.play_arrow,
        color: widget.challengeColor,
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CheckpointDetailScreen(
              checkpoint: checkpoint,
              challenge: widget.challenge,
              challengeColor: widget.challengeColor,
            ),
          ),
        );
      },
      tooltip: isCompleted ? "View submission" : "Start checkpoint",
    );
  }

  Widget? _buildLockedTrailingWidget(bool isLocked) {
    if (!isLocked) return null;
    
    return Icon(
      Icons.lock_outline,
      color: Colors.grey[400],
      size: 20,
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
}