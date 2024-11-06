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
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Method to filter out the logged-in user from the list
  Future<List<BackendUser>> getFilteredUsers() async {
    final firebase_auth.User? firebaseUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      final loggedInEmail = firebaseUser.email;

      // Filter out the logged-in user from the list
      final filteredUsers =
          users.where((user) => user.email != loggedInEmail).toList();
      return filteredUsers;
    } else {
      throw Exception('No user logged in');
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
