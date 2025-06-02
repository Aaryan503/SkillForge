import 'package:flutter/material.dart';

class ChallengeTabBarWidget extends StatelessWidget {
  final int selectedTabIndex;
  final Color challengeColor;
  final Function(int) onTabSelected;

  const ChallengeTabBarWidget({
    Key? key,
    required this.selectedTabIndex,
    required this.challengeColor,
    required this.onTabSelected,
  }) : super(key: key);

  static const List<String> _tabs = ["Checkpoints", "Community"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: _tabs
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final text = entry.value;
              final isSelected = selectedTabIndex == index;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? challengeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(),
      ),
    );
  }
}