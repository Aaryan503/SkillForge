import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeHeader({
    Key? key,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Ready for a new challenge?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      const NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
