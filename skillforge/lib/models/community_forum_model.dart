class CommunityForumMessage {
  final int id;
  final DateTime createdAt;
  final int challengeId;
  final String authorId;
  final String? authorUsername;
  final String content;
  final int? parentId;
  final int? checkpointTag;
  final int upvotes;
  final DateTime updatedAt;
  final bool isUpvoted;
  final List<CommunityForumMessage> replies;

  CommunityForumMessage({
    required this.id,
    required this.createdAt,
    required this.challengeId,
    required this.authorId,
    this.authorUsername,
    required this.content,
    this.parentId,
    this.checkpointTag,
    required this.upvotes,
    required this.updatedAt,
    this.isUpvoted = false,
    this.replies = const [],
  });

  factory CommunityForumMessage.fromJson(Map<String, dynamic> json) {
    return CommunityForumMessage(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      challengeId: json['challenge_id'] as int,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String?,
      content: json['content'] as String,
      parentId: json['parent_id'] as int?,
      checkpointTag: json['checkpoint_tag'] as int?,
      upvotes: json['upvotes'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isUpvoted: json['is_upvoted'] as bool? ?? false,
      replies: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'challenge_id': challengeId,
      'author_id': authorId,
      'author_username': authorUsername,
      'content': content,
      'parent_id': parentId,
      'checkpoint_tag': checkpointTag,
      'upvotes': upvotes,
      'updated_at': updatedAt.toIso8601String(),
      'is_upvoted': isUpvoted,
    };
  }

  CommunityForumMessage copyWith({
    int? id,
    DateTime? createdAt,
    int? challengeId,
    String? authorId,
    String? authorUsername,
    String? content,
    int? parentId,
    int? checkpointTag,
    int? upvotes,
    DateTime? updatedAt,
    bool? isUpvoted,
    List<CommunityForumMessage>? replies,
  }) {
    return CommunityForumMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      challengeId: challengeId ?? this.challengeId,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      checkpointTag: checkpointTag ?? this.checkpointTag,
      upvotes: upvotes ?? this.upvotes,
      updatedAt: updatedAt ?? this.updatedAt,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      replies: replies ?? this.replies,
    );
  }

  bool get isReply => parentId != null;
  
  bool shouldBeVisible(int userCheckpoint) {
    if (checkpointTag == null) return true;
    return userCheckpoint >= checkpointTag!;
  }
}