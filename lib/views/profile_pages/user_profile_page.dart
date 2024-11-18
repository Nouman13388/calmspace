import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_profile_controller.dart'; // Ensure correct import path

class UserProfilePage extends StatelessWidget {
  final UserProfileController controller = Get.put(UserProfileController());

  UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch user profile when the page loads
    controller.fetchUserProfile(19); // Replace with dynamic user ID

    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: [
          IconButton(
            icon: Icon(controller.isLoading.value ? Icons.refresh : Icons.edit),
            onPressed: () {
              if (controller.isLoading.value) {
                controller.fetchUserProfile(19); // Reload data
              } else {
                controller.toggleEditMode();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (controller.isEditMode.value) {
                if (controller.formKey.currentState?.validate() ?? false) {
                  controller.saveProfile();
                  Get.snackbar("Success", "Profile updated successfully!",
                      backgroundColor: Colors.green, colorText: Colors.white);
                }
              }
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: controller.pickImage, // Open image picker
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: controller.pickedImage.value == null
                        ? NetworkImage(
                            controller.profile.value?.profilePicture ??
                                'https://via.placeholder.com/150')
                        : FileImage(controller.pickedImage.value!)
                            as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Display or edit the profile fields
              controller.isEditMode.value
                  ? _buildEditForm() // If in edit mode, show editable fields
                  : _buildProfileDetails(), // Otherwise, show profile details

              SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // Profile details view (non-editable)
  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username: ${controller.username.value}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Location: ${controller.location.value}',
            style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        Text('Bio: ${controller.bio.value}', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // Edit form view (editable fields)
  Widget _buildEditForm() {
    return Form(
      key: controller.formKey, // Form validation key
      child: Column(
        children: [
          // Username Field
          TextFormField(
            initialValue: controller.username.value,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.edit),
            ),
            onChanged: (value) {
              controller.username.value = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username cannot be empty';
              }
              return null; // Validation passed
            },
          ),
          SizedBox(height: 20),

          // Location Field
          TextFormField(
            initialValue: controller.location.value,
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.edit),
            ),
            onChanged: (value) {
              controller.location.value = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Location cannot be empty';
              }
              return null;
            },
          ),
          SizedBox(height: 20),

          // Bio Field
          TextFormField(
            initialValue: controller.bio.value,
            decoration: InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.edit),
            ),
            maxLines: 4,
            onChanged: (value) {
              controller.bio.value = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bio cannot be empty';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
