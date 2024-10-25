import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';

class AuthController extends GetxController {
  final AuthServices _authServices = AuthServices();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;

  Future<UserCredential?> signUpWithEmail(
      String fullName, String email, String password, String confirmPassword, bool isTherapist) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(
          code: 'passwords-not-match', message: 'The passwords do not match.');
    }

    try {
      isLoading.value = true;

      // Check if user or therapist exists in the database
      bool userExists = await _authServices.checkUserExists(email);
      if (userExists) {
        throw Exception('A user or therapist with this email already exists.');
      }

      // Create Firebase user
      UserCredential userCredential = await _authServices.signUpWithEmail(fullName, email, password);

      // Store user data in the database
      if (isTherapist) {
        String specialization = "Default Specialization";
        String bio = "Default Bio";
        await _authServices.storeTherapistData(email, fullName, specialization, bio);
      } else {
        await _authServices.storeUserData(fullName, email, password); // Include password
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow; // Rethrow the exception to handle it elsewhere
    } catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.toString()), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> authenticateTherapist(String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _authServices.signInWithEmail(email, password);

      bool therapistExists = await _authServices.checkUserExists(email);
      if (!therapistExists) {
        Get.snackbar('Error', 'No therapist account found for this email.', snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      if (rememberMe) {
        prefs.setString('email', email);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', rememberMe);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.toString()), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      UserCredential? userCredential = await _authServices.signInWithGoogle();

      // Fetch user data from backend
      final userEmail = googleUser.email;
      final userName = googleUser.displayName;

      // Check if user exists in backend
      bool userExists = await _authServices.checkUserExists(userEmail);
      if (!userExists) {
        // Store user data if they don't exist
        await _authServices.storeUserData(userName!, userEmail, 'defaultPassword123'); // Placeholder password
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.toString()), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authServices.sendPasswordResetEmail(email);
      Get.snackbar('Success', 'Password reset email sent.', snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', mapFirebaseAuthExceptionMessage(e.message ?? 'An error occurred.'), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout(SharedPreferences prefs) async {
    try {
      isLoading.value = true;
      await _authServices.logout();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await prefs.clear();
      Get.snackbar('Logged Out', 'You have successfully logged out.', snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed('/role-selection');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out. Please try again later.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Map Firebase Auth exception messages to user-friendly messages
  String mapFirebaseAuthExceptionMessage(String errorMessage) {
    if (errorMessage.contains('wrong-password')) {
      return 'The password is incorrect.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'No user found with this email.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This user has been disabled.';
    }
    return 'An unknown error occurred.';
  }

  Future<void> authenticateUser(String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      if (rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
      }
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }
}
