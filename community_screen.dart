import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrilligent/widgets/post_dialog.dart';
import 'package:nutrilligent/widgets/post_list.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> addPost(BuildContext context) async {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("You must be logged in.")),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        if (!context.mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("User not found in database.")),
        );
        return;
      }
      final userData = userDoc.data() ?? {};
      final name = userData['name'] ?? 'Anonymous';
      final photoUrl = userData['photoUrl']?.toString() ?? '';

      final captionController = TextEditingController();
      final imageController = TextEditingController();

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => PostDialog(
          captionController: captionController,
          imageController: imageController,
          onPost: () async {
            final caption = captionController.text.trim();
            final imageUrl = imageController.text.trim();

            if (caption.isEmpty) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Caption cannot be empty")),
              );
              return;
            }

            try {
              await FirebaseFirestore.instance.collection('posts').add({
                'userName': name,
                'userPhotoUrl': photoUrl,
                'caption': caption,
                'imageUrl': imageUrl,
                'timestamp': Timestamp.now(),
                'userId': user.uid,
              });

              if (!context.mounted) return;
              Navigator.pop(context);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error posting: ${e.toString()}")),
              );
            }
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Community", style: TextStyle(color: Colors.white)),
      ),
      body: const PostsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPost(context),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
}
