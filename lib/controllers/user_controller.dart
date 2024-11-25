import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class UserController extends GetxController {
  var users = <BackendUser>[].obs;

  // Fetch users from the API and add them to the UI immediately
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Convert data to BackendUser list
        var fetchedUsers = data.map((e) => BackendUser.fromJson(e)).toList();

        // Update users list with fetched data immediately
        users.value = fetchedUsers;

        // Log success message
        print(
            'Successfully fetched ${fetchedUsers.length} users from backend.');
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Fetch a specific user by their ID
  Future<BackendUser?> fetchUser(int userId) async {
    try {
      // Check if users are already fetched, if not, fetch users first
      if (users.isEmpty) {
        print("Users list is empty. Fetching all users first...");
        await fetchUsers(); // Fetch all users if not fetched yet
      }

      // Find the user from the list by their ID
      final user = users.firstWhere(
        (user) => user.id == userId,
      );

      if (user != null) {
        print('User found with ID: $userId \n $user');
        return user; // Return the found user
      } else {
        print('No user found with ID: $userId');
        return null; // Return null if no user found
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
      throw Exception('Error fetching user by ID: $e');
    }
  }

  // Check if the email already exists in Firebase and the backend before signing up
  Future<bool> isEmailExists(String email) async {
    try {
      // First, check if the email exists in Firebase
      final firebase_user = await firebase_auth.FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);

      if (firebase_user.isNotEmpty) {
        print('Email exists in Firebase: $email');
        return true;
      }

      // Second, check if the email exists in the backend
      final response =
          await http.get(Uri.parse('${AppConstants.usersUrl}?email=$email'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          print('Email exists in backend: $email');
          return true;
        }
      }

      return false;
    } catch (e) {
      print("Error checking if email exists: $e");
      return false;
    }
  }

  // Method to get the logged-in user's details based on email match
  Future<int?> getLoggedInUserId() async {
    try {
      final firebase_auth.User? firebaseUser =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final loggedInEmail = firebaseUser.email;
        print("Logged-in email: $loggedInEmail");

        // Fetch users if not already fetched
        if (users.isEmpty) {
          print("Users list is empty, fetching from backend...");
          await fetchUsers(); // Fetch the users list if it's empty
        }

        // Find the user that matches the logged-in email
        final matchedUser = users.firstWhere(
          (user) => user.email == loggedInEmail,
          orElse: () => BackendUser(id: -1, name: '', email: ''),
        );

        if (matchedUser.id != -1) {
          // Log success message
          print('Successfully found user ID: ${matchedUser.id}');
          return matchedUser.id; // Return the user ID if matched
        } else {
          print('No user found with email: $loggedInEmail');
          return null; // No user found with the logged-in email
        }
      } else {
        print('No logged-in user found.');
        return null; // No logged-in user found
      }
    } catch (e) {
      print("Error finding user by email: $e");
      return null;
    }
  }

  // Method to filter out the logged-in user from the list of users
  Future<List<BackendUser>> getFilteredUsers() async {
    try {
      final firebase_auth.User? firebaseUser =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final loggedInEmail = firebaseUser.email;

        // Filter out the logged-in user from the list
        final filteredUsers =
            users.where((user) => user.email != loggedInEmail).toList();

        // Log success message
        print('Filtered out logged-in user from the list.');

        return filteredUsers;
      } else {
        print('No user logged in');
        throw Exception('No user logged in');
      }
    } catch (e) {
      print('Error filtering users: $e');
      throw Exception('Error filtering users: $e');
    }
  }

  // Sign up a new user after checking if the email already exists in Firebase or backend
  Future<void> signUpWithEmail(String fullName, String email, String password,
      String confirmPassword) async {
    if (password != confirmPassword) {
      print('Passwords do not match!');
      return;
    }

    try {
      // First, check if the email exists in Firebase and the backend
      bool emailExists = await isEmailExists(email);

      if (emailExists) {
        print('The email already exists in Firebase or backend.');
        return;
      }

      // Proceed with Firebase sign-up if email does not exist
      final firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assuming you store user data in the backend here
      final newUser = BackendUser(
          id: userCredential.user?.uid.hashCode ?? 0,
          name: fullName,
          email: email);

      // Store user in the backend
      await _storeUserInBackend(newUser);

      // Fetch the updated users list
      await fetchUsers();

      print('User signed up successfully!');
    } catch (e) {
      print('Error during sign-up: $e');
    }
  }

  // Store the user in the backend
  Future<void> _storeUserInBackend(BackendUser user) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.usersUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
        }),
      );

      if (response.statusCode == 200) {
        print('User data stored in backend successfully');
      } else {
        print('Failed to store user in backend');
      }
    } catch (e) {
      print('Error storing user in backend: $e');
    }
  }
}

class BackendUser {
  final int id;
  final String name;
  final String email;

  BackendUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
