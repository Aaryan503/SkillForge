import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';

class ChallengeCommunityTab extends StatelessWidget {
  final Color challengeColor;

  ChallengeCommunityTab({
    Key? key,
    required this.challengeColor,
  }) : super(key: key);

  final List<CommunityPost> _communityPosts = [
    CommunityPost(
      authorName: "Alex Morgan",
      authorAvatar: "https://i.pravatar.cc/150?img=3",
      content: "Day 3 was tough! Anyone else struggling with the nested loops exercise?",
      timestamp: "2 hours ago",
      likes: 12,
      replies: 8,
    ),
    CommunityPost(
      authorName: "Samantha Lee",
      authorAvatar: "https://i.pravatar.cc/150?img=5",
      content: "I created a cheat sheet for the core concepts in Day 2. Happy to share if anyone's interested!",
      timestamp: "Yesterday",
      likes: 24,
      replies: 15,
    ),
    CommunityPost(
      authorName: "David Johnson",
      authorAvatar: "https://i.pravatar.cc/150?img=7",
      content: "The way this challenge is structured really helps me stay consistent. Already seeing improvements in my coding skills!",
      timestamp: "3 days ago",
      likes: 36,
      replies: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Community Discussion",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Post"),
              onPressed: () {
                // Make new post
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _communityPosts.length,
          itemBuilder: (context, index) {
            final post = _communityPosts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(post.authorAvatar),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              post.timestamp,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post.content,
                      style: const TextStyle(height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle like
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.likes.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            // Handle comment
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.replies.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          iconSize: 18,
                          color: Colors.grey[600],
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // Handle share
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}