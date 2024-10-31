import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';

class SignUpFormController extends GetxController {
  var fullName = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var specialization = ''.obs;
  var bio = ''.obs;
  var rememberMe = false.obs;

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email.value = prefs.getString('email') ?? '';
    password.value = prefs.getString('password') ?? '';
    rememberMe.value = prefs.getBool('rememberMe') ?? false;
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      prefs.setString('email', email.value);
      prefs.setString('password', password.value);
      prefs.setBool('rememberMe', true);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.setBool('rememberMe', false);
    }
  }
}

// Main Page
class TherapistSignUpPage extends StatelessWidget {
  const TherapistSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final SignUpFormController formController = Get.put(SignUpFormController());

    // Load preferences when the page is built
    formController.loadPreferences();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Therapist Sign Up'),
      ),
      body: SignUpForm(authController: authController, formController: formController),
    );
  }
}

// Sign Up Form
class SignUpForm extends StatelessWidget {
  final AuthController authController;
  final SignUpFormController formController;

  SignUpForm({required this.authController, required this.formController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sign Up for a Therapist Account',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            hintText: 'Full Name',
            onChanged: (value) => formController.fullName.value = value,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Email',
            initialValue: formController.email.value,
            onChanged: (value) => formController.email.value = value,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Password',
            obscureText: true,
            onChanged: (value) => formController.password.value = value,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Confirm Password',
            obscureText: true,
            onChanged: (value) => formController.confirmPassword.value = value,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Specialization',
            onChanged: (value) => formController.specialization.value = value,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Bio',
            onChanged: (value) => formController.bio.value = value,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 30),
          Obx(() => ElevatedButton(
            onPressed: authController.isLoading.value ? null : () async {
              await _registerTherapist(authController, formController);
              await formController.savePreferences();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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
    );
  }

  Future<void> _registerTherapist(AuthController authController, SignUpFormController formController) async {
    authController.isLoading.value = true;
    try {
      if (formController.password.value != formController.confirmPassword.value) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message: 'Passwords do not match.',
        );
      }
      await authController.signUpWithEmail(
        formController.fullName.value,
        formController.email.value,
        formController.password.value,
        formController.confirmPassword.value,
        true, // isTherapist
      );

      Get.snackbar(
        'Success',
        'Account created successfully! Welcome!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );

      Get.offNamed('/therapist-login', arguments: {'showSnackbar': true});
    } on FirebaseAuthException catch (firebaseError) {
      String message = _getFirebaseErrorMessage(firebaseError);
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      authController.isLoading.value = false;
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please try another.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return error.message ?? 'An error occurred. Please try again.';
    }
  }

  Widget _buildTextField({
    required String hintText,
    bool obscureText = false,
    String? initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
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
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: initialValue), // Initial value for pre-filled fields
    );
  }
}
