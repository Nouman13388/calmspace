import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'; // For reactive state management
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Reactive state for loading
  RxBool isLoading = false.obs;

  // Fetch user by email from the backend
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final url = Uri.parse('${AppConstants.userUrl}?email=$email');
    try {
      final response = await http.get(url);
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user by email: $e');
      rethrow;
    }
  }

  // Sign up a user with email and password
  Future<UserCredential> signUpWithEmail(
      String fullName, String email, String password) async {
    isLoading.value = true; // Start loading
    try {
      // Check if the user already exists in the backend
      if (await checkUserExists(email)) {
        throw Exception('User with this email already exists');
      }

      // Create a new user in Firebase
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in the backend
      await storeUserData(fullName, email, password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error during sign-up: $e');
      throw Exception('Error during sign-up: $e');
    } finally {
      isLoading.value = false; // End loading
    }
  }

  // Store user data in the backend
  Future<void> storeUserData(
      String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse(AppConstants.usersUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body:
          jsonEncode({'name': fullName, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to store user data: ${response.body}');
    }
  }

  // Store therapist data in the backend
  Future<void> storeTherapistData(
      String email, String fullName, String specialization, String bio) async {
    final response = await http.post(
      Uri.parse(AppConstants.professionalsUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user': email,
        'name': fullName,
        'specialization': specialization,
        'bio': bio,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to store therapist data');
    }
  }

  // Check if the user exists in the backend
  Future<bool> checkUserExists(String email) async {
    final response =
        await http.get(Uri.parse('${AppConstants.usersUrl}?email=$email'));

    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      return users.isNotEmpty;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Error checking user existence: ${response.body}');
    }
  }

  // Check if the therapist exists in the backend
  Future<bool> checkTherapistExists(String email) async {
    final response = await http
        .get(Uri.parse('${AppConstants.professionalsUrl}?email=$email'));

    if (response.statusCode == 200) {
      List<dynamic> therapist = jsonDecode(response.body);
      return therapist.isNotEmpty;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Error checking Therapist existence: ${response.body}');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    isLoading.value = true; // Start loading
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Fetch user data from backend after successful login
      final userData = await getUserByEmail(email);
      if (userData != null) {
        if (kDebugMode) {
          print("Fetched user data from backend: ${userData.toString()}");
        }
      } else {
        if (kDebugMode) {
          print("Failed to fetch user data for $email");
        }
      }

      return credential;
    } catch (e) {
      print('Error during sign-in: $e');
      rethrow;
    } finally {
      isLoading.value = false; // End loading
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    isLoading.value = true; // Start loading
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      UserCredential userCredential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      final userEmail = googleUser.email;
      final userName = googleUser.displayName;

      // Check if user exists in backend
      if (!await checkUserExists(userEmail)) {
        await storeUserData(
            userName!, userEmail, 'defaultPassword123'); // Placeholder password
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    } finally {
      isLoading.value = false; // End loading
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    print('Password reset email sent to: $email');
  }

  // Log out user
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Sign out from Google as well
    print('User logged out.');
  }
}
