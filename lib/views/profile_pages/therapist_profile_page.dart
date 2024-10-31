import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/therapist_profile_controller.dart';

class TherapistProfilePage extends StatelessWidget {
  final TherapistProfileController controller = Get.put(TherapistProfileController());

  TherapistProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: Obx(() => controller.isEditing.value
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.toggleEditing,
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
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: controller.isEditing.value ? controller.pickImage : null,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: controller.photoUrl.value.startsWith('http')
                          ? NetworkImage(controller.photoUrl.value)
                          : FileImage(File(controller.photoUrl.value)),
                      child: controller.photoUrl.value.isEmpty && controller.isEditing.value
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    )

                  ),
                ),
                const SizedBox(height: 16.0),
                controller.isEditing.value
                    ? TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: controller.username.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.username.value = value;
                  },
                )
                    : ListTile(
                  title: const Text('Username'),
                  subtitle: Text(controller.username.value),
                ),
                const SizedBox(height: 16.0),
                controller.isEditing.value
                    ? TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: controller.email.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.email.value = value;
                  },
                )
                    : ListTile(
                  title: const Text('Email'),
                  subtitle: Text(controller.email.value),
                ),
                const SizedBox(height: 16.0),
                if (controller.isEditing.value)
                  ElevatedButton(
                    onPressed: controller.saveProfile,
                    child: const Text('Save Profile'),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
