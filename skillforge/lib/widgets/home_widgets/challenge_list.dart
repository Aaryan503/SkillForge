import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';
import 'challenge_card.dart';

class ChallengeList extends StatelessWidget {
  final List<Challenge> challenges;
  final bool isLoading;

  const ChallengeList({
    Key? key,
    required this.challenges,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return ChallengeCard(challenge: challenges[index]);
      },
    );
  }
}