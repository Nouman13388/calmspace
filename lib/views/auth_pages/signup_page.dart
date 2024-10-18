import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Use GetX to manage the controller and SharedPreferences
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Sign Up for an Account',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration('Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration('Password'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration('Confirm Password'),
            ),
            const SizedBox(height: 30),
            // Using Obx to observe the loading state
            Obx(() {
              return ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () => _registerUser(authController, _emailController.text, _passwordController.text, _confirmPasswordController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Sign Up'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser(AuthController authController, String email, String password, String confirmPassword) async {
    authController.isLoading.value = true; // Start loading
    try {
      await authController.signUpWithEmail(email, password, confirmPassword);
      Get.snackbar('Success', 'Account created successfully!'); // Success message
      Get.back(); // Navigate back on success
    } catch (e) {
      // Print the error to the console for debugging
      print('Sign Up Error: $e');
      // Show error message to the user
      Get.snackbar('Error', authController.mapFirebaseAuthExceptionMessage(e.toString())); // Show error
    } finally {
      authController.isLoading.value = false; // Stop loading
    }
  }

  InputDecoration _inputDecoration(String hintText) {
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
        borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
