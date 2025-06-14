import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/providers/challenge_provider.dart';
import '../../models/challenge_model.dart';
import '../../screens/challenge_detail_screen.dart';

class ChallengeCard extends ConsumerWidget {
  final Challenge challenge;

  const ChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color challengeColor = Theme.of(context).primaryColor;
    final challengeState = ref.watch(challengeProvider);
    final actualChallenge = challengeState.allChallenges.firstWhere(
      (c) => c.id == challenge.id,
      orElse: () => challenge,
    );
    final difficultyText = actualChallenge.difficulty.name[0].toUpperCase() + actualChallenge.difficulty.name.substring(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: challengeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        challenge.language.substring(0, 1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: challengeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        challenge.language,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                challenge.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${challenge.participants.length} joined'),
                  const SizedBox(width: 16),
                  Icon(Icons.star, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(difficultyText),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: challenge.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[200],
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(challengeProvider.notifier);
                  },
                  child: const Text('Join'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
