import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrilligent/models/body_progress_photo_model.dart';
import 'package:nutrilligent/services/user_service.dart';
import 'package:nutrilligent/models/user_model.dart';
import 'package:nutrilligent/widgets/add_progress_photo_button.dart';

class BodyProgressGalleryScreen extends StatefulWidget {
  const BodyProgressGalleryScreen({super.key});

  @override
  State<BodyProgressGalleryScreen> createState() =>
      _BodyProgressGalleryScreenState();
}

class _BodyProgressGalleryScreenState extends State<BodyProgressGalleryScreen> {
  final UserService _userService = UserService();
  List<BodyProgressPhoto> photos = [];
  AppUser? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final user = await _userService.getCurrentUserProfile(forceRefresh: true);
    if (user != null) {
      setState(() {
        photos = List.from(user.bodyProgressPhotos);
        currentUser = user;
        photos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3700B3), Colors.transparent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              const Text(
                "Body Progress Gallery",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : photos.isEmpty
              ? const Center(
                  child: Text("No progress photos yet",
                      style: TextStyle(color: Colors.white70)))
              : GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () => _showPhotoDetail(photo),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x4D000000),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(photo.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(photo.timestamp),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  if (photo.note != null &&
                                      photo.note!.isNotEmpty)
                                    Text(
                                      photo.note!,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 10),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: currentUser != null
          ? AddProgressPhotoButton(
              user: currentUser!,
              onPhotoAdded: _loadPhotos,
            )
          : null,
    );
  }

  void _showPhotoDetail(BodyProgressPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(photo.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(photo.timestamp),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (photo.note != null && photo.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(photo.note!,
                        style: const TextStyle(color: Colors.white)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
