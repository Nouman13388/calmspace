import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signUpWithEmail(String fullName, String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  Future<void> storeUserData(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse(AppConstants.usersUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'name': fullName,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to store user data');
    }
  }

  Future<void> storeTherapistData(String email, String fullName, String specialization, String bio) async {
    final response = await http.post(
      Uri.parse(AppConstants.professionalsUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
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

  Future<bool> checkUserExists(String email) async {
    final response = await http.get(Uri.parse('${AppConstants.usersUrl}?email=$email'));

    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      return users.isNotEmpty; // Return true if there's at least one user
    } else if (response.statusCode == 404) {
      return false; // User not found
    } else {
      throw Exception('Error checking user existence: ${response.body}');
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle(String? accessToken, String? idToken) async {
    return await _auth.signInWithCredential(GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    ));
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
