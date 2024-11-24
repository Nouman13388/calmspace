import 'dart:convert';
import 'dart:io'; // For handling File

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:intl/intl.dart'; // For date formatting (optional)

import '../constants/app_constants.dart'; // Add the correct path for your constants
import 'location_controller.dart';
import 'user_controller.dart'; // Import the UserController to get logged-in user's email

class UserProfileController extends GetxController {
  var isLoading = true.obs; // Loading state for UI
  var isEditMode = false.obs; // Edit mode flag
  var profile = Rxn<BackendUser>(); // To hold the profile data
  var profilePicture = ''.obs; // To hold the image path
  var username = ''.obs;
  var location = ''.obs; // To hold location (latitude, longitude)
  var bio = ''.obs;
  var formKey = GlobalKey<FormState>(); // Form validation key
  var pickedImage = Rxn<File>(); // For storing the picked image

  final picker = ImagePicker(); // Image picker instance

  final UserController userController =
      Get.find<UserController>(); // Get UserController instance

  Future<void> fetchUserProfile() async {
    final userId = await userController.getLoggedInUserId();

    if (userId == null) {
      if (kDebugMode) {
        print('No logged-in user found!');
      }
      return;
    }

    if (kDebugMode) {
      print("fetchUserProfile method called with userId: $userId");
    }

    isLoading.value = true; // Start loading indicator

    try {
      final response =
          await http.get(Uri.parse('${AppConstants.profilesUrl}?user=$userId'));
      final userResponse =
          await http.get(Uri.parse('${AppConstants.usersUrl}?id=$userId'));

      if (kDebugMode) {
        print(
            "API request made (Profile API): ${AppConstants.profilesUrl}?user=$userId");
      }
      if (kDebugMode) {
        print(
            "API request made (User API): ${AppConstants.usersUrl}?id=$userId");
      }

      if (response.statusCode == 200 && userResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<dynamic> userData = json.decode(userResponse.body);

        if (kDebugMode) {
          print("Profile data fetched: $data");
        }
        if (kDebugMode) {
          print("User data fetched: $userData");
        }

        if (data.isNotEmpty && userData.isNotEmpty) {
          // Create BackendUser with the correct name from userData
          final userName = userData[0]['name'] as String;

          profile.value = BackendUser.fromJson(data[0], name: userName);

          // Set initial values for form fields
          username.value = profile.value?.name ?? ''; // Fetch the name here
          location.value = profile.value?.location ?? ''; // Initialize location
          bio.value = profile.value?.bio ?? '';

          // Ensure profilePicture is a valid String
          profilePicture.value = profile.value?.profilePicture ?? '';

          // Print the individual details (Name, Location, Bio) to the console
          if (kDebugMode) {
            print("User Name: ${username.value}");
          }
          if (kDebugMode) {
            print("User Location: ${location.value}");
          }
          if (kDebugMode) {
            print("User Bio: ${bio.value}");
          }

          if (kDebugMode) {
            print("User profile loaded successfully: ${profile.value}");
          }
        } else {
          if (kDebugMode) {
            print("No profiles or user data found for this user.");
          }
          // No profile found, reset form values for new profile creation
          username.value = '';
          location.value = '';
          bio.value = '';
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to load profile or user data. Status code: ${response.statusCode}');
        }
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
    } finally {
      isLoading.value = false; // Stop loading indicator when done
      if (kDebugMode) {
        print("Finished loading user profile");
      }
    }
  }

  // Fetch the current location of the user
  Future<void> fetchUserLocation() async {
    if (kDebugMode) {
      print("Fetching user location...");
    }

    try {
      final locationData = await LocationService.getLocation();

      if (locationData != null) {
        location.value =
            '${locationData['latitude']}, ${locationData['longitude']}'; // Store as string
        if (kDebugMode) {
          print("Location fetched: ${location.value}");
        }
      } else {
        if (kDebugMode) {
          print("Location not available.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location: $e");
      }
    }
  }

  // Save the updated profile with dynamic values
  Future<void> saveProfile() async {
    if (kDebugMode) {
      print("Saving profile...");
    }

    // Get the logged-in user's email to assign it to the user field
    final loggedInEmail = (await userController.getLoggedInUserId()) ??
        'user@example.com'; // Default email if no logged-in user is found

    final updatedProfile = {
      'user': loggedInEmail, // Use the logged-in email dynamically
      'bio': bio.value,
      'location': location.value, // Use the fetched location
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
      var url;
      var requestMethod;

      if (profile.value == null) {
        // If profile does not exist, POST (create new profile)
        url = AppConstants.profilesUrl;
        requestMethod = 'POST';
      } else {
        // If profile exists, PUT (update profile)
        url =
            '${AppConstants.profilesUrl}${profile.value?.id}/'; // Use dynamic profile ID
        requestMethod = 'PUT';
      }

      var request = http.MultipartRequest(requestMethod, Uri.parse(url));

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
      if (kDebugMode) {
        print("Sending request to: ${request.url}");
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Profile saved successfully!");
        }
        Get.snackbar("Success", "Profile saved successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        if (kDebugMode) {
          print("Failed to save profile. Status code: ${response.statusCode}");
        }
        final responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print("Response body: $responseBody");
        }
        throw Exception("Failed to save profile");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving profile: $e");
      }
    }
  }

  // Toggle between edit and view mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (kDebugMode) {
      print("Edit mode toggled: ${isEditMode.value}");
    }
  }

  // Pick an image (image picker logic)
  Future<void> pickImage() async {
    if (kDebugMode) {
      print("Picking image...");
    }
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
      if (kDebugMode) {
        print("Picked image: ${pickedImage.value?.path}");
      }
    } else {
      if (kDebugMode) {
        print("No image selected.");
      }
    }
  }
}

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
  factory BackendUser.fromJson(Map<String, dynamic> json, {String? name}) {
    return BackendUser(
      id: json['id'] as int, // Ensure this is an int
      name: name ?? 'No Name', // Fallback to 'No Name' if name is null
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
