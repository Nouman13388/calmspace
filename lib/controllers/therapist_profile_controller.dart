import 'dart:convert';
import 'dart:io'; // For handling File

import 'package:calmspace/controllers/therapist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:intl/intl.dart'; // For date formatting (optional)

import '../constants/app_constants.dart'; // Add the correct path for your constants
import 'user_controller.dart'; // Import the UserController to get logged-in user's email

class TherapistProfileController extends GetxController {
  var isLoading = true.obs; // Loading state for UI
  var isEditMode = false.obs; // Edit mode flag
  var profile = Rxn<Therapist>(); // To hold the profile data
  var profilePicture = ''.obs; // To hold the image path
  var username = ''.obs;
  var location = ''.obs; // To hold location (latitude, longitude)
  var bio = ''.obs;
  var specialization = ''.obs; // New specialization field
  var formKey = GlobalKey<FormState>(); // Form validation key
  var pickedImage = Rxn<File>(); // For storing the picked image

  final picker = ImagePicker(); // Image picker instance
  final UserController userController =
      Get.find<UserController>(); // Get UserController instance
  final TherapistController therapistController =
      Get.find<TherapistController>();

  // Fetch Therapist profile details
  Future<void> fetchTherapistProfile() async {
    final userId = await userController.getLoggedInUserId();
    final therapistId = await therapistController.getLoggedInTherapistId();

    if (userId == null || therapistId == null) {
      print('No logged-in user or therapist found!');
      return;
    }

    isLoading.value = true;

    try {
      final response = await Future.wait([
        http.get(Uri.parse('${AppConstants.profilesUrl}?user=$userId')),
        http.get(Uri.parse('${AppConstants.usersUrl}?id=$userId')),
        http.get(Uri.parse('${AppConstants.professionalsUrl}?id=$therapistId')),
      ]);

      if (response.every((r) => r.statusCode == 200)) {
        final profileData = json.decode(response[0].body);
        final userData = json.decode(response[1].body);
        final professionalData = json.decode(response[2].body);

        if (profileData.isNotEmpty &&
            userData.isNotEmpty &&
            professionalData.isNotEmpty) {
          final userName = userData[0]['name'] as String;
          profile.value = Therapist.fromJson(profileData[0], name: userName);

          // Set initial values for form fields
          username.value = profile.value?.name ?? '';
          location.value = profile.value?.location ?? '';
          bio.value = professionalData[0]['bio'] ?? '';
          specialization.value = professionalData[0]['specialization'] ?? '';
          profilePicture.value = profile.value?.profilePicture ?? '';

          print("Therapist profile loaded successfully: ${profile.value}");
        } else {
          print("No profile data found.");
          resetProfileFields();
        }
      } else {
        print(
            "Failed to load profile data. Status code: ${response[0].statusCode}");
      }
    } catch (e) {
      print("Error fetching therapist profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Reset profile fields if no data is found
  void resetProfileFields() {
    username.value = '';
    location.value = '';
    bio.value = '';
    specialization.value = '';
    profilePicture.value = '';
  }

  // Save the updated therapist profile
  Future<void> saveProfile() async {
    print("Saving therapist profile...");

    final loggedInEmail =
        (await userController.getLoggedInUserId()) ?? 'therapist@example.com';
    final updatedProfile = {
      'user': loggedInEmail,
      'bio': bio.value,
      'specialization': specialization.value,
      'location': location.value,
      'profile_picture': pickedImage.value?.path ?? profilePicture.value,
      'privacy_settings': 'Public',
      'created_at': DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(DateTime.now()),
      'updated_at': DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(DateTime.now()),
    };

    try {
      final isProfileNew = profile.value == null;
      final url = isProfileNew
          ? AppConstants.profilesUrl
          : '${AppConstants.profilesUrl}${profile.value?.id}/';
      final requestMethod = isProfileNew ? 'POST' : 'PUT';

      var request = http.MultipartRequest(requestMethod, Uri.parse(url));
      updatedProfile.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      if (pickedImage.value != null) {
        var pic = await http.MultipartFile.fromPath(
            'profile_picture', pickedImage.value!.path);
        request.files.add(pic);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Therapist profile saved successfully!");
        Get.snackbar("Success", "Profile saved successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
            "Failed to save profile. Status code: ${response.statusCode}. Response: $responseBody");
        throw Exception("Failed to save therapist profile");
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await _isImageTooLarge(file)) {
        print("Image file is too large!");
        return; // Reject if the image is too large (5MB here)
      }

      pickedImage.value = file;
      print("Picked image: ${pickedImage.value?.path}");
    } else {
      print("No image selected.");
    }
  }

  // Check if the selected image file is too large (e.g., 5MB limit)
  Future<bool> _isImageTooLarge(File file) async {
    final fileSize = await file.length();
    return fileSize > 1024 * 1024 * 5; // 5MB limit
  }
}

// Therapist model class
class Therapist {
  final int id;
  final String name;
  final String email;
  final String bio;
  final String location;
  final String profilePicture;
  final String specialization;

  Therapist({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.location,
    required this.profilePicture,
    required this.specialization,
  });

  factory Therapist.fromJson(Map<String, dynamic> json, {String? name}) {
    return Therapist(
      id: json['id'] as int,
      name: name ?? 'No Name',
      email: json['email'] as String? ?? 'No Email',
      bio: json['bio'] as String? ?? 'No Bio',
      location: json['location'] as String? ?? 'No Location',
      profilePicture: json['profile_picture'] as String? ??
          'https://via.placeholder.com/150',
      specialization: json['specialization'] as String? ?? 'No Specialization',
    );
  }

  @override
  String toString() {
    return 'Therapist(id: $id, name: $name, email: $email, bio: $bio, location: $location, profilePicture: $profilePicture, specialization: $specialization)';
  }
}
