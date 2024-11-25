import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/therapist_controller.dart';
import '../../controllers/user_controller.dart';
import '../chat_pages/chat_page.dart';

class TherapistListPage extends StatelessWidget {
  final TherapistController therapistController =
      Get.put(TherapistController());
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    // Fetch therapists and users on page load
    therapistController.fetchTherapists();
    userController.fetchUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Therapist'),
      ),
      body: Obx(() {
        // Check if data is empty, then show loading indicator
        if (therapistController.therapists.isEmpty ||
            userController.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use FutureBuilder to get the filtered therapists
        return FutureBuilder<List<Therapist>>(
          future: therapistController.getFilteredTherapists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No therapists available.'));
            }

            final filteredTherapists = snapshot.data!;

            return ListView.builder(
              itemCount: filteredTherapists.length,
              itemBuilder: (context, index) {
                final therapist = filteredTherapists[index];

                return GestureDetector(
                  onTap: () async {
                    // Get the logged-in user's email using Firebase Auth
                    final firebase_auth.User? firebaseUser =
                        firebase_auth.FirebaseAuth.instance.currentUser;

                    if (firebaseUser != null) {
                      final loggedInEmail = firebaseUser.email;

                      // Print the logged-in user's email for debugging
                      print('Logged-in User Email: $loggedInEmail');

                      // Check if the therapist's email matches the logged-in user's email
                      BackendUser? matchedUser =
                          userController.users.firstWhere(
                        (user) => user.email == loggedInEmail,
                        orElse: () => BackendUser(id: -1, name: '', email: ''),
                      );

                      // If a matching user is found
                      if (matchedUser.id != -1) {
                        // Now we know we have a user and therapist, and we can pass their IDs
                        final userId = matchedUser.id;
                        final therapistId = therapist.id;

                        // Print the matched user and therapist IDs for debugging
                        print('User ID: $userId');
                        print('Therapist ID: $therapistId');

                        // Navigate to the chat page and pass the userId and therapistId
                        Get.to(
                          () => ChatPage(),
                          arguments: {
                            'userId': userId, // Pass the logged-in user's ID
                            'therapistId':
                                therapistId, // Pass the selected therapist's ID
                          },
                        );
                      } else {
                        // Handle case where no matching user is found
                        Get.snackbar(
                            'Error', 'No matching user found for this email');
                      }
                    } else {
                      // Handle case where no user is logged in
                      Get.snackbar('Error', 'User not logged in');
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: ListTile(
                      leading: const CircleAvatar(),
                      title: Text(therapist.name),
                      subtitle:
                          Text(therapist.specialization), // Show specialization
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
