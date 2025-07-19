import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrilligent/widgets/post_card.dart';

class PostsList extends StatelessWidget {
  const PostsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading posts",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No posts yet.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final posts = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final doc = posts[index];
            final data = doc.data() as Map<String, dynamic>;

            return PostCard(
              data: data,
              postId: doc.id,
              currentUserId: currentUserId,
            );
          },
        );
      },
    );
  }
}