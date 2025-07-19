import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostReactionsWidget extends StatefulWidget {
  final String postId;
  final String currentUserId;

  const PostReactionsWidget({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<PostReactionsWidget> createState() => _PostReactionsWidgetState();
}

class _PostReactionsWidgetState extends State<PostReactionsWidget> {
  Future<void> reactToPost(String emoji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    final snapshot = await postRef.get();
    final data = snapshot.data();
    if (data == null) return;

    final userReactions =
        Map<String, dynamic>.from(data['userReactions'] ?? {});
    final reactionCounts =
        Map<String, dynamic>.from(data['reactionCounts'] ?? {});

    final userId = user.uid;
    final oldReaction = userReactions[userId];

    if (oldReaction != null) {
      reactionCounts[oldReaction] = (reactionCounts[oldReaction] ?? 1) - 1;
      if (reactionCounts[oldReaction]! <= 0) {
        reactionCounts.remove(oldReaction);
      }
    }

    userReactions[userId] = emoji;
    reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;

    await postRef.update({
      'userReactions': userReactions,
      'reactionCounts': reactionCounts,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final userReactions =
            Map<String, dynamic>.from(data['userReactions'] ?? {});
        final reactionCounts =
            Map<String, dynamic>.from(data['reactionCounts'] ?? {});
        final userReaction = userReactions[widget.currentUserId];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reactionCounts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: reactionCounts.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${entry.key} ${entry.value}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12),
              child: Wrap(
                spacing: 12,
                children: ['❤️', '😂', '😮', '😢', '😡'].map((emoji) {
                  final isSelected = emoji == userReaction;
                  return GestureDetector(
                    onTap: () => reactToPost(emoji),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white24 : Colors.transparent,
                        border: Border.all(
                          color:
                              isSelected ? Colors.purpleAccent : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
