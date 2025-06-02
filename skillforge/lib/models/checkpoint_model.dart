class Checkpoint {
  final int index;
  final String title;
  final String description;
  final String challenge_id;
  final List<String> completedBy;

  Checkpoint({
    this.index = 1,
    required this.title,
    required this.description,
    required this.challenge_id,
    this.completedBy = const [],
  });
}