import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService.internal();

  static final AuthService _instance = AuthService.internal();

  factory AuthService() {
    return _instance;
  }

  //mengakses firebase authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //memantau perubahan status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //mendaftarkan akun
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error Sign up: ${e.code}');
      return null;
    }
  }

  //login menggunakan akun terdaftar
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error Sign in: ${e.code}');
      return null;
    }
  }

  //logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
