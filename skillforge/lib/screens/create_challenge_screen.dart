import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillforge/screens/create_checkpoint_screen.dart';
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_provider.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _languageController = TextEditingController();
  
  ChallengeDifficulty? _selectedDifficulty;
  List<String> _selectedTags = [];
  bool _isCreating = false;

  // Randomly generated list of tags
  final List<String> _availableTags = [
    'Programming', 'Design', 'Marketing', 'Fitness', 'Learning',
    'Creative', 'Business', 'Technology', 'Health', 'Personal Development',
    'Writing', 'Art', 'Music', 'Photography', 'Cooking', 'Reading',
    'Meditation', 'Finance', 'Leadership', 'Communication', 'Productivity',
    'Gaming', 'Sports', 'Travel', 'Fashion', 'Environment', 'Science',
    'History', 'Languages', 'DIY', 'Social Media', 'Networking'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Create Challenge',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Challenge Details',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Fill in the basic information about your challenge',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title Field
              Text(
                'Challenge Title',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter a compelling title for your challenge',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Description Field
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe what participants will do and learn',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Language Field
              Text(
                'Language',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(
                  hintText: 'e.g., English, Spanish, French',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a language';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Difficulty Dropdown
              Text(
                'Difficulty Level',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ChallengeDifficulty>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  hintText: 'Select difficulty level',
                ),
                items: ChallengeDifficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(_capitalizeFirst(difficulty.name)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a difficulty level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Tags Dropdown
              Text(
                'Tags',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('Select tags for your challenge'),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
                    items: _availableTags.map((tag) {
                      return DropdownMenuItem(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && !_selectedTags.contains(value)) {
                        setState(() {
                          _selectedTags.add(value);
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Selected Tags Display
              if (_selectedTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTags.remove(tag);
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              
              // Preview Card
              if (_titleController.text.isNotEmpty || _descriptionController.text.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _titleController.text.isNotEmpty ? _titleController.text : 'Challenge Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _descriptionController.text.isNotEmpty 
                              ? _descriptionController.text
                              : 'Challenge description will appear here',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_selectedDifficulty != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _capitalizeFirst(_selectedDifficulty!.name),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (_selectedDifficulty != null && _selectedTags.isNotEmpty)
                              const SizedBox(width: 8),
                            if (_selectedTags.isNotEmpty)
                              Text(
                                '${_selectedTags.length} tags',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isCreating ? null : _createChallenge,
          child: _isCreating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create Challenge & Add Checkpoints'),
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _createChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one tag'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Get current user ID from userProvider
      final currentUser = ref.read(userProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create challenge object
      final challenge = Challenge(
        id: '', // Will be generated by backend
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        language: _languageController.text.trim(),
        createdBy: currentUser.userId!, // From userProvider
        participants: [currentUser.userId!], // Creator is automatically a participant
        difficulty: _selectedDifficulty!,
        tags: _selectedTags,
      );

      // Create challenge through provider
      final createdChallenge = await ref.read(challengeProvider.notifier).createChallenge(challenge);

      // Navigate to checkpoint creation screen
      if (mounted) {
        Navigator.of(context).pop();
        // Navigate to checkpoint creation screen (you'll implement this)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateCheckpointsScreen(challengeId: createdChallenge.id, challengeTitle: createdChallenge.title)
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
