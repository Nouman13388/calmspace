import 'dart:convert';
import 'dart:io'; // For handling File

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:intl/intl.dart'; // For date formatting (optional)

import '../constants/app_constants.dart'; // Add the correct path for your constants

class UserProfileController extends GetxController {
  var isLoading = true.obs; // Loading state for UI
  var isEditMode = false.obs; // Edit mode flag
  var profile = Rxn<BackendUser>(); // To hold the profile data
  var profilePicture = ''.obs; // To hold the image path
  var username = ''.obs;
  var location = ''.obs;
  var bio = ''.obs;
  var formKey = GlobalKey<FormState>(); // Form validation key
  var pickedImage = Rxn<File>(); // For storing the picked image

  final picker = ImagePicker(); // Image picker instance

  // Fetch the user profile using the API
  Future<void> fetchUserProfile(int userId) async {
    print("fetchUserProfile method called with userId: $userId");

    isLoading.value = true; // Start loading indicator

    try {
      final response =
          await http.get(Uri.parse('${AppConstants.profilesUrl}?user=$userId'));
      print("API request made: ${AppConstants.profilesUrl}?user=$userId");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Profile data fetched: $data");

        if (data.isNotEmpty) {
          profile.value = BackendUser.fromJson(data[0]);

          // Set initial values for form fields
          username.value = profile.value?.name ?? '';
          location.value = profile.value?.location ?? '';
          bio.value = profile.value?.bio ?? '';

          // Ensure profilePicture is a valid String
          profilePicture.value = profile.value?.profilePicture ?? '';

          print("User profile loaded successfully: ${profile.value}");
        } else {
          print("No profiles found for this user.");
        }
      } else {
        print(
            'Failed to load profile data. Status code: ${response.statusCode}');
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false; // Stop loading indicator when done
      print("Finished loading user profile");
    }
  }

  // Save the updated profile with dynamic values
  Future<void> saveProfile() async {
    if (profile.value == null) {
      print("Profile not found, unable to save.");
      return;
    }

    print("Saving profile...");

    final updatedProfile = {
      'user': profile.value?.id, // Use the profile ID dynamically
      'bio': bio.value,
      'location': location.value,
      'profile_picture': pickedImage.value != null
          ? pickedImage.value!.path // Image file path as String
          : profilePicture.value,
      'privacy_settings': 'Public',
      'created_at': DateFormat('yyyy-MM-ddTHH:mm:ssZ')
          .format(DateTime.now()), // Current time
      'updated_at': DateFormat('yyyy-MM-ddTHH:mm:ssZ')
          .format(DateTime.now()), // Current time
    };

    try {
      // Ensure that the profile id exists
      final profileId = profile.value?.id;
      if (profileId == null) {
        print("Profile ID is null, unable to update.");
        return;
      }

      // Construct the URL with the dynamic profile ID
      var request = http.MultipartRequest(
          'PUT',
          Uri.parse(
              '${AppConstants.profilesUrl}$profileId/') // Use dynamic profile ID
          );

      // Add fields to the request
      request.fields['user'] = updatedProfile['user']?.toString() ?? '';
      request.fields['bio'] = updatedProfile['bio']?.toString() ?? '';
      request.fields['location'] = updatedProfile['location']?.toString() ?? '';
      request.fields['privacy_settings'] =
          updatedProfile['privacy_settings']?.toString() ?? '';
      request.fields['created_at'] =
          updatedProfile['created_at']?.toString() ?? '';
      request.fields['updated_at'] =
          updatedProfile['updated_at']?.toString() ?? '';

      // If an image is picked, add it to the request
      if (pickedImage.value != null) {
        var pic = await http.MultipartFile.fromPath(
            'profile_picture', pickedImage.value!.path);
        request.files.add(pic);
      }

      // Print the request details
      print("Sending request to: ${request.url}");
      var response = await request.send();
      if (response.statusCode == 200) {
        print("Profile updated successfully!");
      } else {
        print("Failed to update profile. Status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      print("Error saving profile: $e");
    }
  }

  // Toggle between edit and view mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    print("Edit mode toggled: ${isEditMode.value}");
  }

  // Pick an image (image picker logic)
  Future<void> pickImage() async {
    print("Picking image...");
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
      print("Picked image: ${pickedImage.value?.path}");
    } else {
      print("No image selected.");
    }
  }
}

// BackendUser class represents the profile object
class BackendUser {
  final int id;
  final String name;
  final String email;
  final String bio;
  final String location;
  final String profilePicture;

  BackendUser({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.location,
    required this.profilePicture,
  });

  // Factory constructor to parse JSON response from API
  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id'] as int, // Ensure this is an int
      name: json['name'] as String? ?? 'No Name', // Cast to String safely
      email: json['email'] as String? ?? 'No Email', // Cast to String safely
      bio: json['bio'] as String? ?? 'No Bio', // Cast to String safely
      location:
          json['location'] as String? ?? 'No Location', // Cast to String safely
      profilePicture: json['profile_picture'] as String? ??
          'https://via.placeholder.com/150', // Default image if null or cast safely
    );
  }

  // Override toString() method for better readability when printing
  @override
  String toString() {
    return 'BackendUser(id: $id, name: $name, email: $email, bio: $bio, location: $location, profilePicture: $profilePicture)';
  }
}
