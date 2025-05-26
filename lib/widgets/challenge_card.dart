import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../screens/challenge_detail_screen.dart';
import '../providers/challenge_provider.dart';

class ChallengeCard extends ConsumerWidget {
  final Challenge challenge;

  const ChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDescription(context),
              const SizedBox(height: 16),
              _buildInfoRow(),
              const SizedBox(height: 12),
              _buildTags(),
              const SizedBox(height: 12),
              _buildJoinButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getChallengeColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              challenge.language.substring(0, 1),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getChallengeColor(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'by ${challenge.createdBy}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildDifficultyBadge(context, challenge.difficulty),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      challenge.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoChip(
          icon: Icons.schedule,
          label: challenge.estimatedTime,
        ),
        const SizedBox(width: 12),
        _buildInfoChip(
          icon: Icons.people,
          label: '${challenge.participants} joined',
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      children: challenge.tags.map((tag) {
        return Chip(
          label: Text(tag),
          backgroundColor: Colors.grey[100],
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildJoinButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ref.read(challengeProvider.notifier).joinChallenge(challenge.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: const Text('Join Challenge'),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context, ChallengeDifficulty difficulty) {
    Color color;
    String text;
    
    switch (difficulty) {
      case ChallengeDifficulty.beginner:
        color = Colors.green;
        text = 'Beginner';
        break;
      case ChallengeDifficulty.intermediate:
        color = Colors.orange;
        text = 'Intermediate';
        break;
      case ChallengeDifficulty.advanced:
        color = Colors.red;
        text = 'Advanced';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getChallengeColor(BuildContext context) {
    switch (challenge.language.toLowerCase()) {
      case 'python':
        return Colors.blue;
      case 'dart':
        return Colors.teal;
      case 'javascript':
        return Colors.amber;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}