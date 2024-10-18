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

  final String apiUrl = 'http://127.0.0.1:8000/api'; // Your API endpoint

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(
      String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      throw FirebaseAuthException(
          code: 'passwords-not-match', message: 'The passwords do not match.');
    }

    try {
      isLoading.value = true;

      // Check if user or therapist exists in the database
      bool userExists = await _checkUserExists(email);
      print('user is $userExists');


      if (userExists ) {
        throw Exception('A user or therapist with this email already exists.');
      }

      // Store user data in the database first
      String userId = await _storeUserData(email,password);
      print('user Id is $userId');


      // If storing user data was successful, create a Firebase user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      print('user issad  $userCredential');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow the exception to handle it elsewhere
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

Future<String> _storeUserData(String email,String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/users/'), // Ensure there's a trailing slash here
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'name': 'Your Name Here',
        'password':password // Ensure you include all required fields
      }),
    );

    if (response.statusCode == 201) {
      final userData = jsonDecode(response.body);
      EndUser user = EndUser.fromJson(userData); // Ensure this line is correct
      return user.email!;
    } else {
      // Log the response for debugging
      print("Error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to store user data');
    }
}

  // Store therapist data in the database
  Future<void> _storeTherapistData(String email, String specialty) async {
    final response = await http.post(
      Uri.parse('$apiUrl/professionals/'), // Ensure there's a trailing slash here
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'specialty': specialty, // Include other required fields as necessary
      }),
    );

    if (response.statusCode == 201) {
      final therapistData = jsonDecode(response.body);
      EndUser therapist = EndUser.fromJson(therapistData); // Ensure this line is correct
    } else {
      throw Exception('Failed to store therapist data');
    }
  }

  // Authenticate user with email and password
  Future<UserCredential?> authenticateUser(
      String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      isLoading.value = true;

      // Check if user data exists in the database first
      bool userExists = await _checkUserExists(email);
      if (!userExists) {
        throw Exception('User data not found in the database.');
      }

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
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Authenticate therapist with email and password
  Future<UserCredential?> authenticateTherapist(
      String email, String password, SharedPreferences prefs, bool rememberMe) async {
    try {
      isLoading.value = true;

      // Check if therapist data exists in the database first
      bool therapistExists = await _checkTherapistExists(email);
      if (!therapistExists) {
        throw Exception('Therapist data not found in the database.');
      }

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
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

// Check if user exists in the database
Future<bool> _checkUserExists(String email) async {
  final response = await http.get(Uri.parse('$apiUrl/users/?email=$email'));

  // Log the response for debugging
  print("Check User Exists Response: ${response.body}");

  if (response.statusCode == 200) {
    // If the response body contains user data, the user exists
    List<dynamic> users = jsonDecode(response.body); // Assuming the response is a list
    return users.isNotEmpty; // Return true if there's at least one user
  } else if (response.statusCode == 404) {
    return false; // User not found
  } else {
    throw Exception('Error checking user existence: ${response.body}');
  }
}

// Check if therapist exists in the database
Future<bool> _checkTherapistExists(String email) async {
  final response = await http.get(Uri.parse('$apiUrl/professionals/?email=$email'));

  // Log the response for debugging
  print("Check Therapist Exists Response: ${response.body}");

  if (response.statusCode == 200) {
    // If the response body contains therapist data, the therapist exists
    List<dynamic> therapists = jsonDecode(response.body); // Assuming the response is a list
    return therapists.isNotEmpty; // Return true if there's at least one therapist
  } else if (response.statusCode == 404) {
    return false; // Therapist not found
  } else {
    throw Exception('Error checking therapist existence: ${response.body}');
  }
}

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      print("Attempting Google Sign-In...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final UserCredential userCredential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      print("Google Sign-In successful: ${userCredential.user?.email}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow to handle it elsewhere
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
}
