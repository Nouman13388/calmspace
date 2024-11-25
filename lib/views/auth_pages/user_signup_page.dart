import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart'; // Import the UserController

class UserSignUpPage extends StatelessWidget {
  UserSignUpPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userController =
        Get.find<UserController>(); // Initialize the UserController

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('User Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Sign Up for a User Account',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _fullNameController,
              decoration: _inputDecoration('Full Name', context),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration('Email', context),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration('Password', context),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration('Confirm Password', context),
            ),
            const SizedBox(height: 30),
            Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () => _registerUser(authController, userController),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser(
      AuthController authController, UserController userController) async {
    authController.isLoading.value = true;

    try {
      // Check if the email already exists in Firebase and the backend
      bool emailExists =
          await userController.isEmailExists(_emailController.text);

      if (emailExists) {
        _showSnackbar('Error', 'Email is already registered!', Colors.red);
        return;
      }

      // Proceed with Firebase sign-up if the email does not exist
      await authController.signUpWithEmail(
        _fullNameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
        false, // isTherapist (assuming the user is not a therapist here)
      );

      _showSnackbar(
          'Success', 'User account created successfully!', Colors.orangeAccent);

      // Navigate to login page after successful sign-up
      Get.offNamed('/user-login'); // Navigate to UserLoginPage
    } catch (e) {
      String errorMessage =
          authController.mapFirebaseAuthExceptionMessage(e.toString());
      _showSnackbar('Error', errorMessage, Colors.red);
      print(errorMessage); // Log the error for debugging
    } finally {
      authController.isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
    );
  }

  InputDecoration _inputDecoration(String hintText, BuildContext context) {
    return InputDecoration(
      labelText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
