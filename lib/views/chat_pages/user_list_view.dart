import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/therapist_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../constants/app_constants.dart';
import 'chat_page.dart';

class UserListPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final TherapistController therapistController =
      Get.put(TherapistController());

  // Your backend URL (from UserController)
  final String usersUrl = AppConstants.usersUrl;

  @override
  Widget build(BuildContext context) {
    // Fetch users and therapists on page load
    userController.fetchUsers();
    therapistController.fetchTherapists();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
      ),
      body: Obx(() {
        // Show loading indicator if data is not available
        if (userController.users.isEmpty ||
            therapistController.therapists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Print fetched data for debugging
        print('Fetched Users:');
        print(userController.users);
        print('Fetched Therapists:');
        print(therapistController.therapists);

        return ListView.builder(
          itemCount: userController.users.length,
          itemBuilder: (context, index) {
            final user = userController.users[index];

            return GestureDetector(
              onTap: () async {
                // Get the logged-in user's email using Firebase Auth
                final firebase_auth.User? firebaseUser =
                    firebase_auth.FirebaseAuth.instance.currentUser;

                if (firebaseUser != null) {
                  final loggedInEmail = firebaseUser.email;

                  // Print the logged-in user's email for debugging
                  print('Logged-in User Email: $loggedInEmail');

                  // Now directly use the selected user's ID (from the tapped card)
                  final userId =
                      user.id; // This is the ID from the selected user card

                  print('Selected User ID: $userId');

                  // Call the function to get the logged-in therapist's ID
                  final therapistId =
                      await therapistController.getLoggedInTherapistId();

                  if (therapistId != null) {
                    print('Matched Therapist ID: $therapistId');

                    // Navigate to the chat page and pass userId and therapistId
                    Get.to(
                      () => ChatPage(),
                      arguments: {
                        'userId': userId, // Pass the selected user's ID
                        'therapistId': therapistId, // Pass the therapist's ID
                      },
                    );
                  } else {
                    // Handle case where no therapist was found
                    print('No therapist found for the logged-in user.');
                    Get.snackbar('Error', 'No therapist found.');
                  }
                } else {
                  // Handle case where no user is logged in
                  print('No user logged in');
                  Get.snackbar('Error', 'User not logged in');
                }
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[
                        0]), // Display the first letter of the user's name
                    backgroundColor: Colors.blueAccent,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
