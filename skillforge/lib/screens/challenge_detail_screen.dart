import 'package:flutter/material.dart';
import '../models/challenge_model.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({Key? key, required this.challenge}) : super(key: key);

  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _isJoined = false;
  int _selectedTabIndex = 0;
  
  // fake daily tasks
  final List<Checkpoint> _dailyTasks = [
    Checkpoint(
      index: 1,
      title: "Getting Started",
      description: "Set up your development environment and learn the basics",
      isCompleted: true,
      challenge_id: '',
    ),
    Checkpoint(
      index: 2,
      title: "Core Concepts",
      description: "Learn about variables, data types, and basic operations",
      isCompleted: true,
      challenge_id: '',
    ),
    Checkpoint(
      index: 3,
      title: "Control Flow",
      description: "Master conditional statements and loops",
      isCompleted: true,
      challenge_id: '',
    ),
    Checkpoint(
      index: 4,
      title: "Functions & Methods",
      description: "Learn how to create reusable blocks of code",
      isCompleted: false,
      challenge_id: '',
    ),
    Checkpoint(
      index: 5,
      title: "Object-Oriented Programming",
      description: "Understand classes, objects, inheritance, and polymorphism",
      isCompleted: false,
      challenge_id: '',
    ),
  ];

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChallengeHeader(),
                  const SizedBox(height: 24),
                  _buildChallengeInfo(),
                  const SizedBox(height: 24),
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: _getChallengeColor(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.challenge.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getChallengeColor(),
                    _getChallengeColor().withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Text(
                  widget.challenge.language.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 200,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: () {
            //TODO: add share
          },
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {
            // TODO: add bookmark
          },
        ),
      ],
    );
  }

  Widget _buildChallengeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getDifficultyColor(), width: 1),
              ),
              child: Text(
                _getDifficultyText(),
                style: TextStyle(
                  color: _getDifficultyColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getChallengeColor().withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getChallengeColor(), width: 1),
              ),
              child: Text(
                widget.challenge.language,
                style: TextStyle(
                  color: _getChallengeColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.challenge.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.challenge.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.challenge.tags.map((tag) {
              return Chip(
                label: Text(tag),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.grey[100],
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildChallengeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.calendar_today_outlined,
                title: "Duration",
                value: widget.challenge.estimatedTime,
              ),
              _buildInfoItem(
                icon: Icons.people_outline,
                title: "Participants",
                value: "${widget.challenge.participants.length} people",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.person_outline,
                title: "Created by",
                value: widget.challenge.createdBy,
              ),
              _buildInfoItem(
                icon: Icons.trending_up,
                title: "Completion Rate",
                value: "78%",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _getChallengeColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabButton(0, "Syllabus"),
          _buildTabButton(1, "Community"),
          _buildTabButton(2, "Resources"),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _getChallengeColor() : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSyllabusTab();
      case 1:
        return _buildCommunityTab();
      case 2:
        return _buildResourcesTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSyllabusTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Challenge Roadmap",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Complete one challenge per day to master ${widget.challenge.language}",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dailyTasks.length,
          itemBuilder: (context, index) {
            final task = _dailyTasks[index];
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: task.isCompleted
                      ? _getChallengeColor()
                      : Colors.grey[300],
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : Text(
                          '${task.index}',
                          style: TextStyle(
                            color: task.isCompleted ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    )
                  ],
                ),
                trailing: task.isCompleted
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.play_arrow),
                        color: _getChallengeColor(),
                        onPressed: () {
                        },
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommunityTab() {
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
                //Make new post
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
                            //TODO: add comment feature
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

  Widget _buildResourcesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Helpful Resources",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Additional materials to help you succeed",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        _buildResourceItem(
          icon: Icons.book_outlined,
          title: "Beginner's Guide",
          description: "Start here if you're new to ${widget.challenge.language}",
          color: Colors.blue,
        ),
        _buildResourceItem(
          icon: Icons.video_library_outlined,
          title: "Video Tutorials",
          description: "Watch step-by-step tutorials for each day's challenge",
          color: Colors.red,
        ),
        _buildResourceItem(
          icon: Icons.code_outlined,
          title: "Code Examples",
          description: "Sample solutions and code snippets",
          color: Colors.green,
        ),
        _buildResourceItem(
          icon: Icons.chat_outlined,
          title: "Discord Community",
          description: "Join our Discord server for live help",
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: _isJoined
            ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Continue Learning"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getChallengeColor(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isJoined = true;
                        });
                        // add join challenge logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getChallengeColor(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Join Challenge"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getChallengeColor() {
    switch (widget.challenge.language.toLowerCase()) {
      case 'python':
        return Colors.blue;
      case 'dart':
        return Colors.teal;
      case 'javascript':
        return Colors.amber;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.challenge.difficulty) {
      case ChallengeDifficulty.beginner:
        return Colors.green;
      case ChallengeDifficulty.intermediate:
        return Colors.orange;
      case ChallengeDifficulty.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyText() {
    switch (widget.challenge.difficulty) {
      case ChallengeDifficulty.beginner:
        return 'Beginner';
      case ChallengeDifficulty.intermediate:
        return 'Intermediate';
      case ChallengeDifficulty.advanced:
        return 'Advanced';
    }
  }
}