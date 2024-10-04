import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;

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

  Future<UserCredential> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // This token can be used to authenticate with your backend
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

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
