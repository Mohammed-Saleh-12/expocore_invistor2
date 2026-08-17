import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../../core/services/services.dart';
import '../../linkapi.dart';

class FirebaseAuthSyncService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Crud _crud = Crud();

  bool get isFirebaseAvailable => !kIsWeb || true;

  Future<String?> syncFirebaseAuthIfNeeded({
    required String email,
    required String password,
    required String userId,
    required String? firebaseUid,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        currentUser = credential.user;
      }

      final uid = currentUser?.uid ?? firebaseUid;
      if (uid == null || uid.isEmpty) {
        return null;
      }

      final result = await _crud.postData(AppLink.firebaseSync, {
        'user_id': userId,
        'email': email,
        'firebase_uid': uid,
        'firebase_provider': 'email',
      });

      if (result['status'] == true) {
        return uid;
      }

      debugPrint('[FirebaseSync] Laravel sync failed: ${result['message']}');
      return uid;
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseSync] Firebase Auth error: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[FirebaseSync] Sync error: $e');
      return null;
    }
  }

  Future<void> signOutFirebase() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<String?> ensureFirebaseUserFromLaravelSession() async {
    try {
      final services = Get.find<Services>();
      final email = services.userEmail;
      final token = services.token;
      final userId = services.userId.toString();
      if (email.isEmpty || token.isEmpty || userId.isEmpty) {
        return null;
      }

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        return currentUser.uid;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
