import 'dart:io';

import 'package:calmspace/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TherapistLoginPage extends StatefulWidget {
  TherapistLoginPage({super.key});

  @override
  _TherapistLoginPageState createState() => _TherapistLoginPageState();
}

class _TherapistLoginPageState extends State<TherapistLoginPage> {
  final _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxBool _rememberMe = false.obs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _emailController.text = prefs.getString('email') ?? '';
    _passwordController.text = prefs.getString('password') ?? '';
    _rememberMe.value = prefs.getBool('rememberMe') ?? false;
  }

  void _loginTherapist() async {
    _isLoading.value = true;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await _authController.authenticateTherapist(
        _emailController.text,
        _passwordController.text,
        prefs,
        _rememberMe.value,
      );
      Get.offAllNamed('/therapist-homepage');
    } catch (e) {
      print('Caught error: $e');

      String errorMessage = _getErrorMessage(e);
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        case 'invalid-credential':
          return 'Invalid Credentials. Please check your email and password.';
        default:
          return 'An unknown error occurred. Please try again.';
      }
    } else if (error is SocketException) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text(
              'Login to Your Therapist Account',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Obx(() => Checkbox(
                        value: _rememberMe.value,
                        onChanged: (value) => _rememberMe.value = value!,
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Remember Me',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: _isLoading.value ? null : _loginTherapist,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading.value
                  ? const CircularProgressIndicator()
                  : const Text('Sign in'),
            )),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => Get.toNamed('/therapist-signup'),
              child: Text(
                "Don't have an account? Sign up",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
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
