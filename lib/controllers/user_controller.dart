import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class UserController extends GetxController {
  var users = <BackendUser>[].obs;

  // Fetch users from the API
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        users.value = data.map((e) => BackendUser.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
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
