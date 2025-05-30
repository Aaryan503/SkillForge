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
    final Color challengeColor = _getChallengeColor(context);

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
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: challengeColor.withOpacity(0.1),
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
                  Text('${challenge.participants} joined'),
                  const SizedBox(width: 16),
                  Icon(Icons.star, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${challenge.difficulty} difficulty'),
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
                    ref.read(challengeProvider.notifier).joinChallenge(challenge.id);
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

  Color _getChallengeColor(BuildContext context) {
    switch (challenge.language.toLowerCase()) {
      case 'flutter':
        return Colors.blue;
      case 'python':
        return Colors.green;
      case 'javascript':
        return Colors.amber;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}
