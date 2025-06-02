import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/models/community_forum_model.dart';
import 'package:skillforge/providers/community_forum_provider.dart';
import '../../models/challenge_model.dart';

class ChallengeCommunityTab extends ConsumerStatefulWidget {
  final Color challengeColor;
  final Challenge challenge;

  const ChallengeCommunityTab({
    Key? key,
    required this.challengeColor,
    required this.challenge,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeCommunityTab> createState() => _ChallengeCommunityTabState();
}

class _ChallengeCommunityTabState extends ConsumerState<ChallengeCommunityTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _replyingToId;
  String? _replyingToUsername;
  int? _selectedCheckpointTag;
  int _userCheckpoint = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(communityForumFamilyProvider(widget.challenge.id).notifier);
      notifier.setUserCheckpoint(_userCheckpoint);
      notifier.loadMessages(widget.challenge.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(communityForumFamilyProvider(widget.challenge.id));
    final forumNotifier = ref.read(communityForumFamilyProvider(widget.challenge.id).notifier);

    if (forumState.isLoading && forumState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (forumState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(forumState.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                forumNotifier.clearError();
                forumNotifier.loadMessages(widget.challenge.id);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.challengeColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.forum,
                color: widget.challengeColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Discussion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.challengeColor,
                      ),
                    ),
                    Text(
                      'Share your progress and help others',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: forumState.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start the conversation and help your fellow learners!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: forumState.messages.length,
                  itemBuilder: (context, index) {
                    return MessageCard(
                      message: forumState.messages[index],
                      onReply: _setReplyTarget,
                      onUpvote: forumNotifier.toggleUpvote,
                      onRemoveCheckpointTag: forumNotifier.removeCheckpointTag,
                      userCheckpoint: _userCheckpoint,
                      challengeColor: widget.challengeColor,
                    );
                  },
                ),
        ),
        _buildMessageInput(forumNotifier),
      ],
    );
  }

  Widget _buildMessageInput(CommunityForumNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingToId != null) _buildReplyIndicator(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _replyingToId != null 
                        ? 'Reply to $_replyingToUsername...'
                        : 'Share your thoughts...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showCheckpointDialog(),
                icon: Icon(
                  _selectedCheckpointTag != null 
                      ? Icons.bookmark 
                      : Icons.bookmark_border,
                  color: _selectedCheckpointTag != null 
                      ? widget.challengeColor 
                      : null,
                ),
                tooltip: 'Add checkpoint tag',
              ),
              IconButton(
                onPressed: _messageController.text.trim().isEmpty
                    ? null
                    : () => _sendMessage(notifier),
                icon: const Icon(Icons.send),
                tooltip: 'Send message',
              ),
            ],
          ),
          if (_selectedCheckpointTag != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: Text('Checkpoint $_selectedCheckpointTag'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _selectedCheckpointTag = null),
                backgroundColor: widget.challengeColor.withValues(alpha: .1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.challengeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.challengeColor.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(Icons.reply, size: 16, color: widget.challengeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to $_replyingToUsername',
              style: TextStyle(color: widget.challengeColor),
            ),
          ),
          IconButton(
            onPressed: _cancelReply,
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showCheckpointDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Checkpoint Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Messages with checkpoint tags are only visible to users who have reached that checkpoint.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedCheckpointTag,
              decoration: const InputDecoration(
                labelText: 'Checkpoint',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                _userCheckpoint + 1,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text('Checkpoint $index'),
                ),
              ),
              onChanged: (value) {
                setState(() => _selectedCheckpointTag = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _setReplyTarget(int messageId, String username) {
    setState(() {
      _replyingToId = messageId;
      _replyingToUsername = username;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToUsername = null;
    });
  }

  void _sendMessage(CommunityForumNotifier notifier) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    await notifier.sendMessage(
      challengeId: widget.challenge.id,
      content: content,
      parentId: _replyingToId,
      checkpointTag: _selectedCheckpointTag,
    );

    _messageController.clear();
    _cancelReply();
    setState(() => _selectedCheckpointTag = null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class MessageCard extends StatelessWidget {
  final CommunityForumMessage message;
  final Function(int, String) onReply;
  final Function(int) onUpvote;
  final Function(int) onRemoveCheckpointTag;
  final int userCheckpoint;
  final Color challengeColor;

  const MessageCard({
    Key? key,
    required this.message,
    required this.onReply,
    required this.onUpvote,
    required this.onRemoveCheckpointTag,
    required this.userCheckpoint,
    required this.challengeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageHeader(context),
            const SizedBox(height: 8),
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildMessageFooter(context),
            if (message.replies.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildReplies(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: challengeColor,
          child: Text(
            (message.authorUsername != null && message.authorUsername!.isNotEmpty
                ? message.authorUsername![0]
                : 'U').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (message.authorUsername != null && message.authorUsername!.isNotEmpty)
                    ? message.authorUsername!
                    : 'Unknown User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (message.checkpointTag != null) ...[
          Chip(
            label: Text(
              'CP ${message.checkpointTag}',
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: Colors.orange[100],
            visualDensity: VisualDensity.compact,
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => onRemoveCheckpointTag(message.id),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageFooter(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => onUpvote(message.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  message.isUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16,
                  color: message.isUpvoted 
                      ? challengeColor 
                      : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  message.upvotes.toString(),
                  style: TextStyle(
                    color: message.isUpvoted 
                        ? challengeColor 
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => onReply(message.id, message.authorUsername ?? 'User'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.reply,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplies(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[300]!, width: 2),
        ),
      ),
      child: Column(
        children: message.replies.map((reply) => 
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: challengeColor.withValues(alpha: 0.7),
                      child: Text(
                        (reply.authorUsername != null && reply.authorUsername!.isNotEmpty
                            ? reply.authorUsername![0]
                            : 'U').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (reply.authorUsername != null && reply.authorUsername!.isNotEmpty)
                                ? reply.authorUsername!
                                : 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatTime(reply.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (reply.checkpointTag != null) ...[
                      Chip(
                        label: Text(
                          'CP ${reply.checkpointTag}',
                          style: const TextStyle(fontSize: 8),
                        ),
                        backgroundColor: Colors.orange[100],
                        visualDensity: VisualDensity.compact,
                        deleteIcon: const Icon(Icons.close, size: 12),
                        onDeleted: () => onRemoveCheckpointTag(reply.id),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () => onUpvote(reply.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              reply.isUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 14,
                              color: reply.isUpvoted 
                                  ? challengeColor 
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              reply.upvotes.toString(),
                              style: TextStyle(
                                color: reply.isUpvoted 
                                    ? challengeColor 
                                    : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => onReply(reply.id, reply.authorUsername ?? 'User'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.reply,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).toList(),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {  
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}