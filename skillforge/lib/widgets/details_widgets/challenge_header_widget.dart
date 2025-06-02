import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';

class ChallengeHeaderWidget extends StatelessWidget {
  final Challenge challenge;
  final Color challengeColor;
  final Color difficultyColor;
  final String difficultyText;

  const ChallengeHeaderWidget({
    Key? key,
    required this.challenge,
    required this.challengeColor,
    required this.difficultyColor,
    required this.difficultyText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: difficultyColor, width: 1),
              ),
              child: Text(
                difficultyText,
                style: TextStyle(
                  color: difficultyColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: challengeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: challengeColor, width: 1),
              ),
              child: Text(
                challenge.language,
                style: TextStyle(
                  color: challengeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          challenge.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
                height: 1.5,
              ),
        ),
        if (challenge.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: challenge.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.grey[100],
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}