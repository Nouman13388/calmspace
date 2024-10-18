import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;

  final String apiUrl = 'http://127.0.0.1:8000/api/users'; // Your API endpoint

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(
      String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(
          code: 'passwords-not-match', message: 'The passwords do not match.');
    }
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store user data in the database
      await _storeUserData(userCredential.user!.uid, email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow the exception to handle it elsewhere
    } finally {
      isLoading.value = false;
    }
  }

  // Store user data in the database
  Future<void> _storeUserData(String userId, String email) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      final userData = jsonDecode(response.body);
      EndUser user = EndUser.fromJson(userData); // Ensure this line is correct
    } else {
      throw Exception('Failed to store user data');
    }
  }

  // Authenticate user with email and password
  Future<UserCredential?> authenticateUser(String email, String password,
      SharedPreferences prefs, bool rememberMe) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (rememberMe) {
        prefs.setString('email', email);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', rememberMe);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow to handle it elsewhere
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      print("Attempting Google Sign-In...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return null; // User canceled the sign-in
      }

      print("Google Sign-In successful: $googleUser");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      print("Firebase Auth successful: ${userCredential.user}");

      // Store user data in the database
      _storeUserData(userCredential.user!.uid, userCredential.user!.email!);

      return userCredential;
    } catch (e) {
      print("Google Sign-In error: $e");
      throw Exception('Google Sign-In failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow to handle it elsewhere
    }
  }

  // Logout user and clear session
  Future<void> logout(SharedPreferences prefs) async {
    try {
      isLoading.value = true;

      await _auth.signOut();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await prefs.clear();

      Get.snackbar('Logged Out', 'You have successfully logged out.',
          snackPosition: SnackPosition.BOTTOM);

      Get.offAllNamed('/role-selection');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out. Please try again later.',
          snackPosition: SnackPosition.BOTTOM);
      throw e; // Rethrow to handle it elsewhere
    } finally {
      isLoading.value = false;
    }
  }

  // Map Firebase Auth Exception Message
  String mapFirebaseAuthExceptionMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'An error occurred. Please try again later.';
    }
  }
}
