import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeInfoWidget extends StatefulWidget {
  final Challenge challenge;
  final Color challengeColor;

  const ChallengeInfoWidget({
    Key? key,
    required this.challenge,
    required this.challengeColor,
  }) : super(key: key);

  @override
  State<ChallengeInfoWidget> createState() => _ChallengeInfoWidgetState();
}

class _ChallengeInfoWidgetState extends State<ChallengeInfoWidget> {
  String? creatorUsername;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCreatorUsernameByEmail();
  }

  Future<void> _fetchCreatorUsernameByEmail() async {
    setState(() {
      _loading = true;
    });
    try {
      final userRow = await Supabase.instance.client
          .from('users')
          .select('username,email')
          .eq('id', widget.challenge.createdBy)
          .maybeSingle();

      String? username;
      if (userRow != null && userRow['email'] != null) {
        final usernameRow = await Supabase.instance.client
            .from('users')
            .select('username')
            .eq('email', userRow['email'])
            .maybeSingle();
        username = usernameRow?['username'] as String? ?? userRow['username'] as String?;
      }

      setState(() {
        creatorUsername = username;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        creatorUsername = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.people_outline, color: widget.challengeColor, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Participants",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.challenge.participants.length} people",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person_outline, color: widget.challengeColor, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Created by",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  _loading
                      ? const SizedBox(
                          width: 60,
                          height: 14,
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      : Text(
                          creatorUsername ?? widget.challenge.createdBy,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}