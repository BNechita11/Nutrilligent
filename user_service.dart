import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../models/body_progress_photo_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger(
    printer: PrettyPrinter(
      colors: true,
      printEmojis: true,
      methodCount: 0,
    ),
  );

  AppUser? _cachedUser;

  Future<AppUser?> getCurrentUserProfile({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedUser != null) return _cachedUser;

      final user = _auth.currentUser;
      if (user == null) {
        logger.w("No authenticated Firebase user found");
        return null;
      }

      logger.i("Fetching user profile for UID: ${user.uid}");
      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (!doc.exists) {
        logger.w("User document does not exist for UID: ${user.uid}");
        return null;
      }

      final data = doc.data();
      if (data == null) {
        logger.e(
            "User document exists but contains no data for UID: ${user.uid}");
        return null;
      }

      logger.i("Successfully retrieved user profile for UID: ${user.uid}");
      _cachedUser = AppUser.fromMap(user.uid, data);
      return _cachedUser;
    } on FirebaseException catch (e) {
      logger.e("Firestore error while fetching user profile",
          error: e, stackTrace: e.stackTrace);
      return null;
    } on Exception catch (e, stackTrace) {
      logger.e("Unexpected error while fetching user profile",
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection("users").doc(user.id).update(user.toMap());
      _cachedUser = user;
      logger.i("Successfully updated profile for UID: ${user.id}");
    } on FirebaseException catch (e) {
      logger.e("Error updating user profile",
          error: e, stackTrace: e.stackTrace);
      rethrow;
    }
  }

  Future<void> updateBodyProgressPhotos(List<BodyProgressPhoto> photos) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'bodyProgressPhotos': photos.map((p) => p.toMap()).toList(),
    });

    _cachedUser = _cachedUser?.copyWith(bodyProgressPhotos: photos);
  }

  Future<AppUser?> getUserProfile(String uid) async{
    try
    {
      final doc = await _firestore.collection("users").doc(uid).get();
      if(!doc.exists) return null;
      final data = doc.data();
      if(data == null) return null;
      return AppUser.fromMap(uid, data);
    }
    on FirebaseException catch (e)
    {
      logger.e("Error fetching profile for UID $uid", error: e);
      return null;
    }
  }
}
