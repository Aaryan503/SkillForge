import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';
import 'challenge_checkpoint_tab.dart';
import 'challenge_community_tab.dart';

class ChallengeTabContentWidget extends StatelessWidget {
  final int selectedTabIndex;
  final Challenge challenge;
  final Color challengeColor;

  const ChallengeTabContentWidget({
    Key? key,
    required this.selectedTabIndex,
    required this.challenge,
    required this.challengeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (selectedTabIndex) {
      case 0:
        return ChallengeCheckpointTab(
          challenge: challenge,
          challengeColor: challengeColor,
        );
      case 1:
        return ChallengeCommunityTab(challengeColor: challengeColor);
      default:
        return const SizedBox.shrink();
    }
  }
}