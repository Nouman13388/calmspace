import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/therapist_profile_controller.dart'; // Ensure correct import path

class TherapistProfilePage extends StatelessWidget {
  final TherapistProfileController controller =
      Get.put(TherapistProfileController());

  TherapistProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchTherapistProfile(); // Fetch profile data

    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapist Profile"),
        actions: [
          // Show the edit button only when not in edit mode
          Obx(() {
            return Visibility(
              visible: !controller.isEditMode.value,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  controller.toggleEditMode(); // Enter edit mode
                },
              ),
            );
          }),
          // Show the save button only when in edit mode
          Obx(() {
            return Visibility(
              visible: controller.isEditMode.value,
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  if (controller.formKey.currentState?.validate() ?? false) {
                    controller.saveProfile(); // Save the profile
                    controller.toggleEditMode(); // Exit edit mode after saving
                  }
                },
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: controller.isEditMode.value
                      ? controller
                          .pickImage // Open image picker only if in edit mode
                      : null,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: controller.pickedImage.value == null
                        ? NetworkImage(
                            controller.profile.value?.profilePicture ??
                                'https://via.placeholder.com/150')
                        : FileImage(controller.pickedImage.value!)
                            as ImageProvider,
                    child: controller.isEditMode.value &&
                            controller.pickedImage.value == null
                        ? const Icon(Icons.camera_alt,
                            color: Colors.white,
                            size: 30) // Show camera icon only in edit mode
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              controller.profile.value != null
                  ? (controller.isEditMode.value
                      ? _buildEditForm()
                      : _buildProfileDetails())
                  : _buildNoProfilePrompt(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileDetailRow(
            Icons.account_circle, 'Username', controller.username.value),
        const SizedBox(height: 12),
        _buildProfileDetailRow(
            Icons.location_on, 'Location', controller.location.value),
        const SizedBox(height: 12),
        _buildProfileDetailRow(
            Icons.star, 'Specialization', controller.specialization.value),
        const SizedBox(height: 12),
        _buildProfileDetailRow(Icons.edit, 'Bio', controller.bio.value),
      ],
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildTextFormField(
            'Username',
            controller.username.value,
            (value) {
              controller.username.value = value;
            },
            icon: Icons.account_circle,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            'Location',
            controller.location.value,
            (value) {
              controller.location.value = value;
            },
            icon: Icons.location_on,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            'Specialization',
            controller.specialization.value,
            (value) {
              controller.specialization.value = value;
            },
            icon: Icons.star,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            'Bio',
            controller.bio.value,
            (value) {
              controller.bio.value = value;
            },
            icon: Icons.edit,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    String initialValue,
    Function(String) onChanged, {
    int maxLines = 1,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildNoProfilePrompt() {
    return Column(
      children: [
        const Text(
          'No profile found!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'It looks like you haven\'t set up your profile yet. Please add your details below to get started!',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildProfileForm(),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildTextFormField(
            'Username',
            '',
            (value) {
              controller.username.value = value;
            },
            icon: Icons.account_circle,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            'Location',
            '',
            (value) {
              controller.location.value = value;
            },
            icon: Icons.location_on,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            'Specialization',
            '',
            (value) {
              controller.specialization.value = value;
            },
            icon: Icons.star,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            'Bio',
            '',
            (value) {
              controller.bio.value = value;
            },
            icon: Icons.edit,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
