import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../models/tips_model.dart';

class TipsController extends GetxController {
  var users = <Map<String, dynamic>>[].obs; // List of users
  var isLoading = true.obs; // Loading status

  // Fetch users from API
  Future<void> fetchUsers() async {
    isLoading(true); // Start loading
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));
      if (response.statusCode == 200) {
        List<dynamic> fetchedUsers = jsonDecode(response.body);
        users.value = List<Map<String, dynamic>>.from(fetchedUsers);
      } else {
        if (kDebugMode) {
          print('Failed to fetch users. Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
    } finally {
      isLoading(false); // Stop loading
    }
  }

  // Function to assign a tip to a user
  Future<void> assignTipToUser(Tip tip) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.assessmentsUrl}?email=${tip.userEmail}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(tip.toJson()),
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Tip successfully assigned.');
        }
        Get.snackbar(
          'Success',
          'Tip assigned to ${tip.userEmail}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        if (kDebugMode) {
          print('Failed to assign tip. Status Code: ${response.statusCode}');
        }
        Get.snackbar(
          'Error',
          'Failed to assign tip. Try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning tip: $e');
      }
    }
  }
}
