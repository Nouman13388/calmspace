import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/therapist_controller.dart';
import '../../../controllers/user_controller.dart';
import '../chat_pages/chat_page.dart';

class UserListPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final TherapistController therapistController =
      Get.put(TherapistController());

  UserListPage({super.key});

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

        return FutureBuilder<List<BackendUser>>(
          future: userController.getFilteredUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users available.'));
            }

            final filteredUsers = snapshot.data!;

            return ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];

                return GestureDetector(
                  onTap: () async {
                    // Now directly use the selected user's ID (from the tapped card)
                    final userId = user.id;

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
          },
        );
      }),
    );
  }
}
