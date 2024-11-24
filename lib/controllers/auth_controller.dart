import 'package:calmspace/controllers/therapist_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_services.dart';

class AuthController extends GetxController {
  final AuthServices _authServices = AuthServices();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;
  final Rx<EndUser?> userData = Rx<EndUser?>(null); // EndUser model instance

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print("AuthController initialized");
    }
  }

  void onControllerDeleted() {
    if (kDebugMode) {
      print("AuthController removed");
    }
    super.onDelete(); // This calls the parent class's onDelete method
  }

  @override
  void onClose() {
    onControllerDeleted();
  }

  // Fetch user data by email
  Future<void> fetchUserByEmail(String email) async {
    try {
      isLoading.value = true;
      if (kDebugMode) {
        print('Fetching user data for email: $email');
      }

      final fetchedData = await _authServices.getUserByEmail(email);
      if (kDebugMode) {
        print('Fetched data: $fetchedData');
      }

      if (fetchedData != null) {
        userData.value = EndUser.fromJson(fetchedData);
        if (kDebugMode) {
          print(
              'User data loaded: ${userData.value?.email} ${userData.value?.name} ${userData.value?.id}');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userData.value!.email!);
        await prefs.setString('user_name', userData.value!.name!);
        await prefs.setInt('user_id', userData.value!.id!);

        if (kDebugMode) {
          print('User data fetched and saved successfully!');
        }
      } else {
        if (kDebugMode) {
          print('No user found with this email.');
        }
      }
    } catch (e) {
      showErrorSnackbar(
        title: 'Oops!',
        message:
            'Something went wrong while fetching user data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final id = prefs.getInt('user_id');

    if (email != null && name != null && id != null) {
      userData.value = EndUser(email: email, name: name, id: id);
      if (kDebugMode) {
        print('User data loaded: ${userData.value}');
      }
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String fullName, String email,
      String password, String confirmPassword, bool isTherapist) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(
          code: 'passwords-not-match', message: 'The passwords do not match.');
    }

    try {
      isLoading.value = true;

      bool userExists = await _authServices.checkUserExists(email);
      if (userExists) {
        throw Exception('A user or therapist with this email already exists.');
      }

      UserCredential userCredential =
          await _authServices.signUpWithEmail(fullName, email, password);

      if (isTherapist) {
        String specialization = "Default Specialization";
        String bio = "Default Bio";
        await _authServices.storeTherapistData(
            email, fullName, specialization, bio);
      } else {
        await _authServices.storeUserData(fullName, email, password);
      }
      userData.value = EndUser(email: email, name: fullName);

      showSuccessSnackbar(
        title: 'Welcome!',
        message: 'You have successfully signed up, $fullName!',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      showErrorSnackbar(
        title: 'Registration Failed',
        message:
            e.message ?? 'An unexpected error occurred during registration.',
      );
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Something went wrong: ${e.toString()}');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showErrorSnackbar(
          title: 'Sign-In Aborted',
          message: 'Please try signing in with Google again.',
        );
        throw Exception('Google sign-in aborted');
      }

      UserCredential? userCredential = await _authServices.signInWithGoogle();

      final userEmail = googleUser.email;
      final userName = googleUser.displayName;

      bool userExists = await _authServices.checkUserExists(userEmail);
      if (!userExists) {
        await _authServices.storeUserData(
            userName!, userEmail, 'defaultPassword123');
      }

      await fetchUserByEmail(userEmail);

      showSuccessSnackbar(
        title: 'Welcome Back!',
        message: 'You are now signed in as $userName!',
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print(
            'An error occurred while signing in: ${mapFirebaseAuthExceptionMessage(e.toString())}');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Log out the user
  Future<void> logout(SharedPreferences prefs) async {
    try {
      isLoading.value = true;
      await _authServices.logout();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await prefs.clear();
      userData.value = null;
      showSuccessSnackbar(
        title: 'Goodbye!',
        message: 'You have successfully logged out. Come back soon!',
      );
      Get.offAllNamed('/role-selection');
    } catch (e) {
      showErrorSnackbar(
        title: 'Error',
        message: 'Failed to log out. Please try again later.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> authenticateTherapist(
    String email,
    String password,
    SharedPreferences prefs,
    bool rememberMe,
  ) async {
    try {
      isLoading.value = true;

      // Ensure the TherapistController is initialized
      Get.put(TherapistController());

      // Initialize therapist controller and fetch therapists
      final therapistController = Get.find<TherapistController>();
      await therapistController.fetchTherapists();

      // Check if therapist with the given email exists
      final therapistExists = therapistController.therapists
          .any((therapist) => therapist.email == email);

      if (!therapistExists) {
        // Therapist not found, stop here
        if (kDebugMode) {
          print('No therapist account found for this email: $email.');
        }
        showErrorSnackbar(
          title: 'Error',
          message:
              'No therapist account found for this email. Please check and try again.',
        );
        return null;
      }

      // Proceed with Firebase Authentication
      if (kDebugMode) {
        print('Therapist found. Proceeding with Firebase Authentication...');
      }

      // Attempt Firebase sign-in
      UserCredential userCredential =
          await _authServices.signInWithEmail(email, password);

      if (userCredential.user != null) {
        // If Firebase authentication is successful
        if (kDebugMode) {
          print('Firebase authentication successful for email: $email.');
        }

        // Handle "Remember Me" logic if successful
        if (rememberMe) {
          prefs.setString('email', email);
          prefs.setString('password', password);
          prefs.setBool('rememberMe', rememberMe);
          if (kDebugMode) {
            print('Credentials saved for "Remember Me".');
          }
        }
        return userCredential; // Return the Firebase UserCredential
      } else {
        // Firebase authentication failed
        if (kDebugMode) {
          print('Firebase authentication failed for email: $email');
        }
        showErrorSnackbar(
          title: 'Authentication Failed',
          message:
              'Unable to sign in. Please check your credentials and try again.',
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Catch Firebase Authentication exceptions
      String errorMessage = _getFirebaseAuthErrorMessage(e);
      if (kDebugMode) {
        print('Firebase Authentication Error: $errorMessage');
      }

      showErrorSnackbar(
        title: 'Authentication Error',
        message: errorMessage,
      );
      return null; // Return null for FirebaseAuthException
    } catch (e) {
      // Catch any other errors
      if (kDebugMode) {
        print('An error occurred during authentication: ${e.toString()}');
      }

      showErrorSnackbar(
        title: 'Error',
        message: 'An unexpected error occurred. Please try again later.',
      );
      return null; // Return null for any other exception
    } finally {
      // Reset loading state, regardless of success or failure
      isLoading.value = false;
      if (kDebugMode) {
        print('Authentication process complete.');
      }
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    // Debugging: Print the error code and message for debugging purposes
    if (kDebugMode) {
      print('FirebaseAuthError: Code: ${e.code}, Message: ${e.message}');
    }

    // Check specific error codes
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      return 'The email or password you entered is incorrect. Please try again.';
    } else if (e.code == 'user-disabled') {
      return 'This user has been disabled.';
    } else if (e.code == 'too-many-requests') {
      return 'Too many login attempts. Please try again later.';
    } else if (e.code == 'invalid-credential') {
      return 'Invalid credentials. Please check your email and password.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is not valid. Please enter a valid email.';
    } else if (e.code == 'email-already-in-use') {
      return 'The email address is already associated with another account.';
    } else if (e.code == 'account-exists-with-different-credential') {
      return 'An account already exists with the same email but different sign-in credentials.';
    } else if (e.code == 'credential-already-in-use') {
      return 'This credential is already associated with a different user account.';
    } else if (e.code == 'requires-recent-login') {
      return 'This operation requires recent login. Please log in again.';
    } else if (e.code == 'provider-already-linked') {
      return 'This account is already linked to the provider.';
    } else if (e.code == 'invalid-verification-code') {
      return 'The verification code is invalid. Please check and try again.';
    } else if (e.code == 'invalid-verification-id') {
      return 'The verification ID is invalid. Please restart the verification process.';
    } else if (e.code == 'quota-exceeded') {
      return 'The project has exceeded its SMS quota. Please try again later.';
    } else if (e.code == 'unverified-email') {
      return 'This operation requires a verified email address.';
    } else if (e.code == 'user-token-expired') {
      return 'Your session has expired. Please log in again.';
    } else if (e.code == 'user-mismatch') {
      return 'The credentials do not match the currently signed-in user.';
    } else if (e.code == 'app-not-authorized') {
      return 'This app is not authorized to use Firebase Authentication.';
    } else if (e.code == 'invalid-phone-number') {
      return 'The phone number format is invalid. Please enter a valid phone number.';
    } else if (e.code == 'missing-phone-number') {
      return 'A phone number is required to complete the operation.';
    } else if (e.code == 'internal-error') {
      return 'An internal error occurred. Please try again later.';
    } else if (e.code == 'network-request-failed') {
      return 'Network error. Please check your internet connection and try again.';
    } else if (e.code == 'expired-action-code') {
      return 'The action code has expired. Please try again.';
    } else if (e.code == 'invalid-action-code') {
      return 'The action code is invalid. Please check the link and try again.';
    } else {
      if (kDebugMode) {
        print('Unhandled FirebaseAuthException code: ${e.code}');
      }
      return 'An unknown error occurred during authentication. Please try again later.';
    }
  }

  // Send password reset email
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authServices.sendPasswordResetEmail(email);
      showSuccessSnackbar(
        title: 'Success!',
        message:
            'A password reset email has been sent to $email. Please check your inbox!',
      );
    } on FirebaseAuthException catch (e) {
      showErrorSnackbar(
        title: 'Error',
        message:
            'Failed to send password reset email: ${mapFirebaseAuthExceptionMessage(e.message ?? 'An error occurred.')}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Map FirebaseAuthException to user-friendly messages
  String mapFirebaseAuthExceptionMessage(String errorMessage) {
    if (kDebugMode) {
      print(errorMessage);
    } // Log the error for debugging purposes

    if (errorMessage.contains('wrong-password')) {
      return 'The password is incorrect. Please try again.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'No user found with this email. Please check your entry.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (errorMessage.contains('invalid-credential') ||
        errorMessage.contains('malformed-credential') ||
        errorMessage.contains('expired-credential')) {
      return 'The supplied authentication credential is invalid, malformed, or expired. Please sign in again.';
    } else {
      // If no specific condition matches, return a generic message
      return 'An unknown error occurred. Please try again later.';
    }
  }

  // Authenticate user
  Future<void> authenticateUser(String email, String password,
      SharedPreferences prefs, bool rememberMe) async {
    try {
      // After successful login, fetch the user data
      await fetchUserByEmail(email);

      // Optionally, store credentials in SharedPreferences if 'rememberMe' is true
      if (rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
      }
    } catch (e) {
      // Handle any exceptions or failed sign-in attempts
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Print user data for debugging
  void printUserData() {
    if (userData.value != null) {
      if (kDebugMode) {
        print('User Data:');
      }
      if (kDebugMode) {
        print('Email: ${userData.value?.email}');
      }
      if (kDebugMode) {
        print('Name: ${userData.value?.name}');
      }
      if (kDebugMode) {
        print('ID: ${userData.value?.id}');
      }
    } else {
      if (kDebugMode) {
        print('No user data available.');
      }
    }
  }

  // Show error snackbar
  void showErrorSnackbar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
    );
  }

  // Show success snackbar
  void showSuccessSnackbar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
