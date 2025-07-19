import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrilligent/models/body_progress_photo_model.dart';
import 'package:nutrilligent/models/user_model.dart';

class AddProgressPhotoButton extends StatefulWidget {
  final AppUser user;
  final VoidCallback onPhotoAdded;

  const AddProgressPhotoButton({
    super.key,
    required this.user,
    required this.onPhotoAdded,
  });

  @override
  State<AddProgressPhotoButton> createState() => _AddProgressPhotoButtonState();
}

class _AddProgressPhotoButtonState extends State<AddProgressPhotoButton> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickImageAndSave() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final note = await _askForNote();
    _noteController.clear();

    if (!mounted || note == null || note.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final newPhoto = BodyProgressPhoto(
        imageUrl: file.path,
        note: note,
        timestamp: DateTime.now(),
      );

      final newList = [...widget.user.bodyProgressPhotos, newPhoto];

      await FirebaseFirestore.instance.collection('users').doc(uid).update(
          {'bodyProgressPhotos': newList.map((p) => p.toMap()).toList()});

      widget.onPhotoAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error adding progress photo")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<String?> _askForNote() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title:
            const Text("Optional note", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _noteController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
              hintText: "Enter a short note",
              hintStyle: TextStyle(color: Colors.white38)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _noteController.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.purple,
      onPressed: _isUploading ? null : _pickImageAndSave,
      child: _isUploading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.add_a_photo),
    );
  }
}
