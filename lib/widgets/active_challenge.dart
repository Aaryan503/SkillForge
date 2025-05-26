import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/challenge_model.dart';
import '../screens/challenge_detail_screen.dart';

class ActiveChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ActiveChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue Learning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildChallengeCard(context),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(child: _buildChallengeInfo()),
                _buildPlayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return CircularPercentIndicator(
      radius: 30.0,
      lineWidth: 6.0,
      animation: true,
      percent: challenge.progress ?? 0.0,
      center: Text(
        '${((challenge.progress ?? 0) * 100).round()}%',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildChallengeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Day ${challenge.daysCompleted}/${challenge.estimatedTime.split(' ')[0]}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            challenge.language,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return IconButton(
      icon: const Icon(
        Icons.play_circle_fill,
        color: Colors.white,
        size: 42,
      ),
      onPressed: () {
      },
    );
  }
}