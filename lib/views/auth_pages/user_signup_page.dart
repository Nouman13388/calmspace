import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class UserSignUpPage extends StatelessWidget {
  UserSignUpPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

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
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _fullNameController,
              decoration: _inputDecoration('Full Name'),
            ),
            const SizedBox(height: 20),
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
            ElevatedButton(
              onPressed: authController.isLoading.value
                  ? null
                  : () => _registerUser(authController),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser(AuthController authController) async {
    authController.isLoading.value = true;
    try {
      await authController.signUpWithEmail(
        _fullNameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
        false, // isTherapist
      );
      Get.snackbar('Success', 'User account created successfully!');
      Get.back(); // Navigate back only after a successful signup
    } catch (e) {
      Get.snackbar('Error', authController.mapFirebaseAuthExceptionMessage(e.toString()));
    } finally {
      authController.isLoading.value = false;
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
