
class Challenge {
  final String id;
  final String title;
  final String description;
  final String estimatedTime;
  final String language;
  final String createdBy;
  final int participants;
  final String coverImage;
  final ChallengeDifficulty difficulty;
  final List<String> tags;
  final double? progress;
  final int? daysCompleted;

  Challenge({
    required this.id, 
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.language,
    required this.createdBy,
    this.participants = 0,
    this.coverImage = '',
    this.difficulty = ChallengeDifficulty.intermediate,
    this.tags = const [],
    this.progress,
    this.daysCompleted,
  });
}

enum ChallengeDifficulty {
  beginner,
  intermediate,
  advanced,
}

class DailyTask {
  final int day;
  final String title;
  final String description;
  final bool isCompleted;
  final int durationMinutes;

  DailyTask({
    required this.day,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.durationMinutes,
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