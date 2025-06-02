class Challenge {
  final int id;
  final String title;
  final String description;
  final String language;
  final String createdBy;
  final List<String> participants;
  final ChallengeDifficulty difficulty;
  final List<String> tags;

  Challenge({
    required this.id, 
    required this.title,
    required this.description,
    required this.language,
    required this.createdBy,
    required this.participants,
    this.difficulty = ChallengeDifficulty.intermediate,
    this.tags = const [],
  });
}

enum ChallengeDifficulty {
  beginner,
  intermediate,
  advanced,
}

class CommunityPost {
  final String authorName;
  final String authorAvatar;
  final String content;
  final String timestamp;
  final int likes;
  final int replies;

  CommunityPost({
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.replies = 0,
  });
}