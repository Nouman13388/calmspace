import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/therapist_controller.dart';
import '../../controllers/user_controller.dart';
import 'booking_page.dart'; // Import the BookingPage

class TherapistAppointmentPage extends StatelessWidget {
  final TherapistController therapistController =
      Get.put(TherapistController());
  final UserController userController = Get.put(UserController());

  TherapistAppointmentPage({super.key});

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
        // Show loading indicator if data is not available
        if (therapistController.therapists.isEmpty ||
            userController.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

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

                      // Find the matched user by email
                      BackendUser? matchedUser =
                          userController.users.firstWhere(
                        (user) => user.email == loggedInEmail,
                        orElse: () => BackendUser(id: -1, name: '', email: ''),
                      );

                      // If a matching user is found
                      if (matchedUser.id != -1) {
                        final userId = matchedUser.id;
                        final therapistId = therapist.id;

                        // Navigate to the BookingPage and pass userId, therapistId, and emails
                        Get.to(
                          () => BookingPage(
                            userId: userId,
                            therapistId: therapistId,
                            userEmail: matchedUser.email, // Pass user email
                            therapistEmail: therapist
                                .email, // Pass therapist email directly
                          ),
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
                      subtitle: Text(therapist.specialization),
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
