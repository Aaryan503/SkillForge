
class Challenge {
  final String id;
  final String title;
  final String description;
  final String estimatedTime;
  final String language;
  final String createdBy;
  final List<String> participants;
  final ChallengeDifficulty difficulty;
  final List<String> tags;

  Challenge({
    required this.id, 
    required this.title,
    required this.description,
    required this.estimatedTime,
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

class Checkpoint {
  final int index;
  final String title;
  final String description;
  final bool isCompleted;
  final String challenge_id;

  Checkpoint({
    this.index = 1,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.challenge_id,
  });
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