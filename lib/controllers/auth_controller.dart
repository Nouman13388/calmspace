import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(code: 'passwords-not-match', message: 'The passwords do not match.');
    }
    try {
      isLoading.value = true;
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Authenticate user with email and password
  Future<UserCredential?> authenticateUser(String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (rememberMe) {
        prefs.setString('email', email);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', rememberMe);
      }

      return userCredential;
    } catch (e) {
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the authentication details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential using the Google credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // Logout user and clear session
  Future<void> logout(SharedPreferences prefs) async {
    try {
      isLoading.value = true;

      // Sign out from Firebase Auth
      await _auth.signOut();

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Clear saved login details from SharedPreferences
      await prefs.clear();

      // Show confirmation snackbar
      Get.snackbar(
        'Logged Out',
        'You have successfully logged out.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to role selection or login page after logout
      Get.offAllNamed('/role-selection');
    } catch (e) {
      // Handle logout error
      Get.snackbar(
        'Error',
        'Failed to log out. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw e;
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
