import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkpoint_model.dart';
import '../models/challenge_model.dart';
import '../providers/checkpoint_provider.dart';
import '../providers/user_provider.dart';
import '../providers/challenge_provider.dart';

class CheckpointDetailScreen extends ConsumerStatefulWidget {
  final Checkpoint checkpoint;
  final Challenge challenge;
  final Color challengeColor;

  const CheckpointDetailScreen({
    Key? key,
    required this.checkpoint,
    required this.challenge,
    required this.challengeColor,
  }) : super(key: key);

  @override
  ConsumerState<CheckpointDetailScreen> createState() => _CheckpointDetailScreenState();
}

class _CheckpointDetailScreenState extends ConsumerState<CheckpointDetailScreen> {
  final TextEditingController _submissionController = TextEditingController();
  final FocusNode _submissionFocusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoJoinChallengeIfNeeded();
    });
  }

  @override
  void dispose() {
    _submissionController.dispose();
    _submissionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _autoJoinChallengeIfNeeded() async {
    final userId = ref.read(userProvider).userId;
    if (userId == null) return;

    final challenge = widget.challenge;
    if (!challenge.participants.contains(userId)) {
      try {
        await ref.read(challengeProvider.notifier).joinChallenge(challenge.id, userId);
      } catch (e) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider).userId;
    final isCompleted = userId != null && widget.checkpoint.completedBy.contains(userId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Checkpoint ${widget.checkpoint.index}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.challengeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.challengeColor,
                    widget.challengeColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.checkpoint.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.challenge.title} • ${widget.challenge.language}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200]!,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              color: widget.challengeColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Challenge Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.checkpoint.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200]!,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.code_outlined,
                              color: widget.challengeColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Solution',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _submissionFocusNode.hasFocus 
                                  ? widget.challengeColor 
                                  : Colors.grey[300]!,
                              width: _submissionFocusNode.hasFocus ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _submissionController,
                            focusNode: _submissionFocusNode,
                            maxLines: 12,
                            enabled: true,
                            decoration: InputDecoration(
                              hintText: isCompleted 
                                  ? 'You have already completed this checkpoint! (You can still submit again)'
                                  : 'Write your code solution here...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.4,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submissionController.text.trim().isNotEmpty && !_isSubmitting
                                ? _submitSolution
                                : null,
                            icon: _isSubmitting
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(_isSubmitting ? 'Submitting...' : 'Submit Solution'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.challengeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),
                        if (!isCompleted) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: !_isSubmitting ? _markAsCompleted : null,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Mark as Completed'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: widget.challengeColor,
                                side: BorderSide(color: widget.challengeColor),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Congratulations! You have completed this checkpoint.',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSolution() async {
    if (_submissionController.text.trim().isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = ref.read(userProvider).userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await ref.read(checkpointProvider.notifier).updateCheckpointCompletion(
        widget.challenge.id,
        widget.checkpoint.index,
        userId,
        true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Solution submitted successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Continue',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }

      _submissionController.clear();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit solution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _markAsCompleted() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = ref.read(userProvider).userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await ref.read(checkpointProvider.notifier).updateCheckpointCompletion(
        widget.challenge.id,
        widget.checkpoint.index,
        userId,
        true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Checkpoint marked as completed!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Continue',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as completed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}