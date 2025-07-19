import 'package:flutter/material.dart';

class PostDialog extends StatelessWidget {
  final TextEditingController captionController;
  final TextEditingController imageController;
  final VoidCallback onPost;

  const PostDialog({
    super.key,
    required this.captionController,
    required this.imageController,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text("Create Post", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Write something...",
                hintStyle: TextStyle(color: Colors.white70),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Image URL (optional)",
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
        ),
        TextButton(
          onPressed: onPost,
          child:
              const Text("Post", style: TextStyle(color: Colors.greenAccent)),
        ),
      ],
    );
  }
}