import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';

class UserProfilePage extends StatelessWidget {
  final TherapistProfileController controller =
      Get.put(TherapistProfileController());

  UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: Obx(() => controller.isEditing.value
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  controller.toggleEditing();
                  controller.fetchUserData();
                },
              )
            : Container()),
        actions: [
          Obx(() => !controller.isEditing.value
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: controller.toggleEditing,
                )
              : Container()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Form(
            key: controller.formKey,
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: controller.isEditing.value
                        ? controller.pickImage
                        : null,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: controller.photoUrl.value.isNotEmpty
                          ? (controller.photoUrl.value.startsWith('http')
                              ? NetworkImage(controller.photoUrl.value)
                              : FileImage(File(controller.photoUrl.value)))
                          : null,
                      child: controller.photoUrl.value.isEmpty &&
                              controller.isEditing.value
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextField('Name', controller.username, (value) {
                  controller.username.value = value;
                }, controller.isEditing.value),
                const SizedBox(height: 16.0),
                _buildTextField('Email', controller.email, (value) {
                  controller.email.value = value;
                }, controller.isEditing.value, isEmail: true),
                const SizedBox(height: 16.0),
                if (controller.isEditing.value)
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.formKey.currentState?.validate() ??
                          false) {
                        await controller.saveProfile();
                      }
                    },
                    child: const Text('Save Profile'),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField(String label, RxString observable,
      Function(String) onChanged, bool isEditing,
      {bool isEmail = false}) {
    final TextEditingController controller =
        TextEditingController(text: observable.value);
    return isEditing
        ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a $label';
              }
              if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              onChanged(value);
              observable.value = value; // Update observable directly
            },
          )
        : ListTile(
            title: Text(label),
            subtitle: Text(observable.value),
          );
  }
}
