import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';

class TherapistProfileController extends GetxController {
  var username = ''.obs;
  var email = ''.obs;
  var bio = ''.obs;
  var location = ''.obs;
  var photoUrl = ''.obs;
  var privacySettings = ''.obs;
  var isEditing = false.obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? selectedImage;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        userId = user.uid;
        email.value = user.email ?? 'No Email';

        // Fetch the display name from Firebase Auth (use as username)
        username.value = user.displayName ??
            'No Name'; // Default to 'No Name' if displayName is null

        // Check if the user has a profile picture from Google Sign-In or Firebase
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          photoUrl.value = user.photoURL!;
        }

        await fetchUserProfile(userId!);
      } else {
        _showError('No user is currently signed in.');
      }
    } catch (e) {
      _showError('Error fetching user data: $e');
    }
  }

  Future<void> fetchUserProfile(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.profilesUrl}$id/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // If backend provides username (in case displayName is empty), update it
        if (data['user'] != null && username.value == 'No Name') {
          username.value = data['user']?.toString() ?? 'No Name';
        }

        bio.value = data['bio'] ?? '';
        location.value = data['location'] ?? '';
        privacySettings.value = data['privacy_settings']?.toString() ?? '0';

        // Update photoUrl from backend if available
        if (data['profile_picture'] != null) {
          photoUrl.value = data['profile_picture'];
        }
      } else {
        _showError('Failed to load profile data');
      }
    } catch (e) {
      _showError('An error occurred while fetching profile data: $e');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        photoUrl.value = pickedFile.path; // Update to use selected image
      } else {
        _showError('No image selected');
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> saveProfile() async {
    if (email.value.isEmpty) {
      _showError('Email is empty. Cannot save profile.');
      return;
    }

    final user = await getUserByEmail(email.value);
    if (user == null) {
      _showError('User not found with email: ${email.value}');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.profilesUrl}${user.id}/'),
      );

      request.fields['bio'] =
          bio.value.isNotEmpty ? bio.value : 'No bio provided';
      request.fields['location'] =
          location.value.isNotEmpty ? location.value : 'No location provided';

      // Ensure privacySettings is a String before assigning
      request.fields['privacy_settings'] = privacySettings.value.toString();

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
              'profile_picture', selectedImage!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        fetchUserProfile(user.id! as String);
      } else {
        _showError('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to save profile: $e');
    }
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  void _showError(String message) {
    print('Error: $message');
  }

  Future<EndUser?> getUserByEmail(String email) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.userUrl}?email=$email'));

      if (response.statusCode == 200) {
        return EndUser.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }
}
