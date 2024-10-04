import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.put(AuthController());
    final TextEditingController _emailController = TextEditingController();
    final Rx<ScreenState> _currentState = ScreenState.Forgot.obs; // Observable state

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_currentState.value == ScreenState.Forgot ? 'Forgot Password' : 'Congratulations')),
      ),
      body: Obx(() => _buildScreen(_currentState.value, _emailController, _authController, _currentState)),
    );
  }

  Widget _buildScreen(ScreenState currentState, TextEditingController emailController, AuthController authController, Rx<ScreenState> currentStateObs) {
    switch (currentState) {
      case ScreenState.Forgot:
        return _buildForgotPage(emailController, authController, currentStateObs);
      case ScreenState.Congratulation:
        return _buildCongratulationScreen();
      default:
        return Container();
    }
  }

  Widget _buildForgotPage(TextEditingController emailController, AuthController authController, Rx<ScreenState> currentStateObs) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Please enter your email address to request a password reset"),
          const SizedBox(height: 30),
          TextField(
            controller: emailController,
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => _sendForgotPasswordEmail(emailController, authController, currentStateObs),
            child: const Text("SEND"),
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const Text("An email has been sent to your email address."),
          const SizedBox(height: 70),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Use GetX for navigation
            },
            child: const Text("Go To Login"),
          ),
        ],
      ),
    );
  }

  void _sendForgotPasswordEmail(TextEditingController emailController, AuthController authController, Rx<ScreenState> currentStateObs) async {
    try {
      await authController.forgotPassword(emailController.text);
      // Update the state to show the congratulation screen
      currentStateObs.value = ScreenState.Congratulation; // Update observable directly
    } catch (e) {
      Get.snackbar(
        'Error',
        authController.mapFirebaseAuthExceptionMessage(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Get.theme.primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

enum ScreenState { Forgot, Congratulation }
