import 'package:calmspace/controllers/therapist_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    print("AuthController initialized");
  }

  void onControllerDeleted() {
    print("AuthController removed");
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
      print('Fetching user data for email: $email');

      final fetchedData = await _authServices.getUserByEmail(email);
      print('Fetched data: $fetchedData');

      if (fetchedData != null) {
        userData.value = EndUser.fromJson(fetchedData);
        print(
            'User data loaded: ${userData.value?.email} ${userData.value?.name} ${userData.value?.id}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userData.value!.email!);
        await prefs.setString('user_name', userData.value!.name!);
        await prefs.setInt('user_id', userData.value!.id!);

        print('User data fetched and saved successfully!');
      } else {
        print('No user found with this email.'); // Changed snackbar to print
      }
    } catch (e) {
      Get.snackbar(
        'Oops!',
        'Something went wrong while fetching user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
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
      print('User data loaded: ${userData.value}');
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

      Get.snackbar(
        'Welcome!',
        'You have successfully signed up, $fullName!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.message ?? 'An unexpected error occurred during registration.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      rethrow;
    } catch (e) {
      print('Something went wrong: ${e.toString()}');
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
        Get.snackbar(
          'Sign-In Aborted',
          'Please try signing in with Google again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
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

      Get.snackbar(
        'Welcome Back!',
        'You are now signed in as $userName!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print(
          'An error occurred while signing in: ${mapFirebaseAuthExceptionMessage(e.toString())}');
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
      Get.snackbar(
        'Goodbye!',
        'You have successfully logged out. Come back soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      Get.offAllNamed('/role-selection');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
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
        print('No therapist account found for this email: $email.');
        Get.snackbar(
          'Error',
          'No therapist account found for this email. Please check and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return null; // Return null since therapist doesn't exist
      }

      // Proceed with Firebase Authentication
      print('Therapist found. Proceeding with Firebase Authentication...');

      // Attempt Firebase sign-in
      UserCredential userCredential =
          await _authServices.signInWithEmail(email, password);

      if (userCredential.user != null) {
        // If Firebase authentication is successful
        print('Firebase authentication successful for email: $email.');

        // Handle "Remember Me" logic if successful
        if (rememberMe) {
          prefs.setString('email', email);
          prefs.setString('password', password);
          prefs.setBool('rememberMe', rememberMe);
          print('Credentials saved for "Remember Me".');
        }
        return userCredential; // Return the Firebase UserCredential
      } else {
        // Firebase authentication failed
        print('Firebase authentication failed for email: $email');
        Get.snackbar(
          'Authentication Failed',
          'Unable to sign in. Please check your credentials and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return null; // Authentication failed
      }
    } on FirebaseAuthException catch (e) {
      // Catch Firebase Authentication exceptions
      String errorMessage = _getFirebaseAuthErrorMessage(e);
      print('Firebase Authentication Error: $errorMessage');

      Get.snackbar(
        'Authentication Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return null; // Return null for FirebaseAuthException
    } catch (e) {
      // Catch any other errors
      print('An error occurred during authentication: ${e.toString()}');

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return null; // Return null for any other exception
    } finally {
      // Reset loading state, regardless of success or failure
      isLoading.value = false;
      print('Authentication process complete.');
    }
  }

// Helper function to handle FirebaseAuthException errors
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'An unknown error occurred during authentication.';
    }
  }

  // Send password reset email
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authServices.sendPasswordResetEmail(email);
      Get.snackbar(
        'Success!',
        'A password reset email has been sent to $email. Please check your inbox!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send password reset email: ${mapFirebaseAuthExceptionMessage(e.message ?? 'An error occurred.')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Map FirebaseAuthException to user-friendly messages
  String mapFirebaseAuthExceptionMessage(String errorMessage) {
    if (errorMessage.contains('wrong-password')) {
      return 'The password is incorrect. Please try again.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'No user found with this email. Please check your entry.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    return 'An unknown error occurred. Please try again later.';
  }

  // Authenticate user
  Future<void> authenticateUser(String email, String password,
      SharedPreferences prefs, bool rememberMe) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

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
      print('User Data:');
      print('Email: ${userData.value?.email}');
      print('Name: ${userData.value?.name}');
      print('ID: ${userData.value?.id}');
    } else {
      print('No user data available.');
    }
  }
}
