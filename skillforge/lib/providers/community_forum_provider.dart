import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/models/community_forum_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityForumState {
  final List<CommunityForumMessage> messages;
  final bool isLoading;
  final String? error;
  final int userCheckpoint;

  const CommunityForumState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.userCheckpoint = 0,
  });

  CommunityForumState copyWith({
    List<CommunityForumMessage>? messages,
    bool? isLoading,
    String? error,
    int? userCheckpoint,
  }) {
    return CommunityForumState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userCheckpoint: userCheckpoint ?? this.userCheckpoint,
    );
  }
}

class CommunityForumNotifier extends StateNotifier<CommunityForumState> {
  CommunityForumNotifier() : super(const CommunityForumState());

  final SupabaseClient _supabase = Supabase.instance.client;

  void setUserCheckpoint(int checkpoint) {
    state = state.copyWith(userCheckpoint: checkpoint);
  }

  Future<void> loadMessages(int challengeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Debug: print challengeId being used
      print('Loading messages for challengeId: $challengeId');
      final response = await _supabase
          .from('community_posts')
          .select()
          .eq('challenge_id', challengeId) // challengeId should be int
          .order('created_at', ascending: true);

      // Debug: print response from Supabase
      print('Supabase response for challengeId $challengeId: $response');

      final List<CommunityForumMessage> allMessages = (response as List)
          .map((json) => CommunityForumMessage.fromJson(json))
          .toList();

      final Map<int, CommunityForumMessage> messageMap = {
        for (var msg in allMessages) msg.id: msg.copyWith(replies: [])
      };
      final List<CommunityForumMessage> rootMessages = [];

      for (var msg in allMessages) {
        if (msg.parentId != null) {
          final parent = messageMap[msg.parentId];
          if (parent != null) {
            parent.replies.add(msg);
          }
        } else {
          rootMessages.add(messageMap[msg.id]!);
        }
      }

      final filteredMessages = _filterMessagesByCheckpoint(rootMessages);

      state = state.copyWith(
        messages: filteredMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages: ${e.toString()}',
      );
    }
  }

  Future<void> sendMessage({
    required int challengeId,
    required String content,
    int? parentId,
    int? checkpointTag,
  }) async {
    try {
      final now = DateTime.now();
      final user = Supabase.instance.client.auth.currentUser;
      final authorId = user?.id ?? '';
      final authorUsername = user?.userMetadata?['username'] ?? user?.email ?? 'User';

      final insertData = {
        'challenge_id': challengeId,
        'author_id': authorId,
        'author_username': authorUsername,
        'content': content,
        'parent_id': parentId,
        'checkpoint_tag': checkpointTag,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'upvotes': 0,
      };

      final inserted = await _supabase
          .from('community_posts')
          .insert(insertData)
          .select()
          .single();

      final newMessage = CommunityForumMessage.fromJson(inserted);

      List<CommunityForumMessage> updatedMessages;
      if (parentId != null) {
        updatedMessages = _addReplyToMessage(state.messages, parentId, newMessage);
      } else {
        updatedMessages = [...state.messages, newMessage];
      }

      final filteredMessages = _filterMessagesByCheckpoint(updatedMessages);

      state = state.copyWith(messages: filteredMessages);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  Future<void> toggleUpvote(int messageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final updatedMessages = _toggleUpvoteInMessages(state.messages, messageId);
      final filteredMessages = _filterMessagesByCheckpoint(updatedMessages);
      state = state.copyWith(messages: filteredMessages);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to toggle upvote: ${e.toString()}',
      );
    }
  }

  Future<void> removeCheckpointTag(int messageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final updatedMessages = _removeCheckpointTagFromMessages(state.messages, messageId);
      final filteredMessages = _filterMessagesByCheckpoint(updatedMessages);
      state = state.copyWith(messages: filteredMessages);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to remove checkpoint tag: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  List<CommunityForumMessage> _filterMessagesByCheckpoint(List<CommunityForumMessage> messages) {
    return messages.where((message) {
      if (message.shouldBeVisible(state.userCheckpoint)) {
        return true;
      }
      return false;
    }).map((message) {
      final filteredReplies = message.replies.where((reply) {
        return reply.shouldBeVisible(state.userCheckpoint);
      }).toList();
      return message.copyWith(replies: filteredReplies);
    }).toList();
  }

  List<CommunityForumMessage> _addReplyToMessage(
    List<CommunityForumMessage> messages,
    int parentId,
    CommunityForumMessage reply,
  ) {
    return messages.map((message) {
      if (message.id == parentId) {
        return message.copyWith(replies: [...message.replies, reply]);
      }
      return message;
    }).toList();
  }

  List<CommunityForumMessage> _toggleUpvoteInMessages(
    List<CommunityForumMessage> messages,
    int messageId,
  ) {
    return messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(
          upvotes: message.isUpvoted ? message.upvotes - 1 : message.upvotes + 1,
          isUpvoted: !message.isUpvoted,
        );
      }
      final updatedReplies = message.replies.map((reply) {
        if (reply.id == messageId) {
          return reply.copyWith(
            upvotes: reply.isUpvoted ? reply.upvotes - 1 : reply.upvotes + 1,
            isUpvoted: !reply.isUpvoted,
          );
        }
        return reply;
      }).toList();
      return message.copyWith(replies: updatedReplies);
    }).toList();
  }

  List<CommunityForumMessage> _removeCheckpointTagFromMessages(
    List<CommunityForumMessage> messages,
    int messageId,
  ) {
    return messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(checkpointTag: null);
      }
      final updatedReplies = message.replies.map((reply) {
        if (reply.id == messageId) {
          return reply.copyWith(checkpointTag: null);
        }
        return reply;
      }).toList();
      return message.copyWith(replies: updatedReplies);
    }).toList();
  }
}

final communityForumProvider = StateNotifierProvider<CommunityForumNotifier, CommunityForumState>(
  (ref) => CommunityForumNotifier(),
);

final communityForumFamilyProvider = StateNotifierProvider.family<CommunityForumNotifier, CommunityForumState, int>(
  (ref, challengeId) {
    final notifier = CommunityForumNotifier();
    Future.microtask(() => notifier.loadMessages(challengeId));
    return notifier;
  },
);