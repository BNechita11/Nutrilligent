import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutrilligent/widgets/comment_sheet.dart';
import 'package:nutrilligent/screens/me_screen.dart';
import 'package:nutrilligent/widgets/post_reactions_widget.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String currentUserId;
  final String postId;

  const PostCard({
    super.key,
    required this.data,
    required this.currentUserId,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final likes = List<String>.from(data['likes'] ?? []);
    final hasLiked = likes.contains(currentUserId);
    final authorId = data['userId'] as String;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                data['userName'] ?? "Unknown",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _formatTimestamp(data['timestamp']),
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeScreen(
                      userId: authorId,
                      isEditable: authorId == currentUserId,
                    ),
                  ),
                );
              },
            ),
            if (data['caption'] != null && data['caption'] != '')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(data['caption'],
                    style: const TextStyle(color: Colors.white)),
              ),
            const SizedBox(height: 8),
            if (data['imageUrl'] != null &&
                data['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "Failed to load image",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: hasLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      final postRef = FirebaseFirestore.instance
                          .collection('posts')
                          .doc(postId);

                      if (hasLiked) {
                        await postRef.update({
                          'likes': FieldValue.arrayRemove([currentUserId])
                        });
                      } else {
                        await postRef.update({
                          'likes': FieldValue.arrayUnion([currentUserId])
                        });
                      }
                    },
                  ),
                  Text(
                    "${likes.length} likes",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        isScrollControlled: true,
                        builder: (_) => CommentSheet(postId: postId),
                      );
                    },
                    child: const Text("View comments",
                        style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ),

            PostReactionsWidget(
              postId: postId,
              currentUserId: currentUserId,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return "${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
