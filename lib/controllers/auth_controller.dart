// controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(
      String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(
          code: 'passwords-not-match', message: 'The passwords do not match.');
    }
    try {
      isLoading.value = true;
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    } finally {
      isLoading.value = false;
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
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
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
      rethrow;
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
