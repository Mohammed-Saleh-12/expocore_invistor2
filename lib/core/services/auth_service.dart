import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../../core/services/services.dart';
import '../../data/sourcedata/remote/Auth/LoginData.dart';
import '../../linkapi.dart';

class AuthService extends GetxService {
  final Crud _crud = Crud();
  final LoginData _loginData = LoginData(Crud());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _loginData.login(email, password);
    if (result['status'] != true) return result;

    final data = result['data'];
    final payload = data is Map ? data['data'] ?? data : data;
    if (payload is! Map) return result;

    final token = payload['token'] ?? payload['access_token'] ?? '';
    final user = payload['user'] ?? payload;
    final userId = (user['id'] as num?)?.toInt() ?? 0;
    final emailValue = (user['email'] ?? '').toString();
    final company = (user['company_name'] ?? user['companyName'] ?? '')
        .toString();
    final role = (user['role'] ?? 'investor').toString();
    final expiresIn = (payload['expires_in'] as num?)?.toInt() ?? 0;

    await Get.find<Services>().saveUserData(
      token: token.toString(),
      company: company,
      email: emailValue,
      userId: userId,
      role: role,
      tokenExpiresInSeconds: expiresIn,
    );

    if (emailValue.isNotEmpty && token.toString().isNotEmpty) {
      try {
        final firebaseUid = await _syncFirebaseAuth(
          email: emailValue,
          password: password,
          userId: userId.toString(),
        );
        if (firebaseUid != null) {
          final syncResult = await _crud.postData(AppLink.firebaseSync, {
            'user_id': userId,
            'email': emailValue,
            'firebase_uid': firebaseUid,
            'firebase_provider': 'email',
          });
          debugPrint('[AuthService] Firebase sync result: $syncResult');
        }
      } catch (_) {}
    }

    return result;
  }

  Future<Map<String, dynamic>> register({
    required Map<String, dynamic> payload,
  }) async {
    final result = await _crud.postData(AppLink.register, payload);
    return result;
  }

  Future<void> logout() async {
    try {
      await _crud.postData(AppLink.logout, {});
    } catch (_) {}
    await _auth.signOut();
    await Get.find<Services>().clearSession();
  }

  Future<String?> _syncFirebaseAuth({
    required String email,
    required String password,
    required String userId,
  }) async {
    try {
      if (kIsWeb) {
        return null;
      }
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        currentUser = credential.user;
      }
      return currentUser?.uid;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService] FirebaseAuthException: ${e.code} - ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[AuthService] Firebase sync error: $e');
      return null;
    }
  }
}
