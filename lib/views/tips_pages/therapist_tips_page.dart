import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../constants/app_constants.dart';
import '../../models/tips_model.dart';

class TherapistTipsPage extends StatefulWidget {
  const TherapistTipsPage({super.key});

  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TherapistTipsPage> {
  var users = <Map<String, dynamic>>[].obs; // List of users
  var isLoading = true.obs; // Loading status

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("TherapistTipsPage initialized");
    }
    fetchUsers();
  }

  // Function to fetch users from the API and get their emails and IDs
  Future<void> fetchUsers() async {
    isLoading(true); // Start loading
    if (kDebugMode) {
      print("Fetching users from API...");
    }
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));

      if (response.statusCode == 200) {
        List<dynamic> fetchedUsers = jsonDecode(response.body);
        users.value = List<Map<String, dynamic>>.from(fetchedUsers);
        if (kDebugMode) {
          print('Users fetched: ${users.length}');
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch users. Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
    } finally {
      isLoading(false); // Stop loading
      if (kDebugMode) {
        print("Finished fetching users.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (isLoading.value) {
          if (kDebugMode) {
            print("Loading users...");
          }
          return const Center(child: CircularProgressIndicator());
        }

        if (users.isEmpty) {
          if (kDebugMode) {
            print("No users found.");
          }
          return const Center(
            child: Text(
              'No users found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        if (kDebugMode) {
          print("Rendering user list...");
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                user['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Email: ${user['email']}'), // Show email
              onTap: () {
                if (kDebugMode) {
                  print(
                      "User ${user['name']} tapped. Navigating to assign tips page.");
                }
                // Navigate to the Assign Tips Page with user email and id
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignTipsPage(
                      userId: user['id'], // Pass selected user ID
                      userEmail: user['email'], // Pass selected user email
                      userName: user['name'], // Pass selected user name
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

// A separate page to assign tips to a specific user
class AssignTipsPage extends StatefulWidget {
  final int userId; // Added userId
  final String userEmail;
  final String userName;

  const AssignTipsPage(
      {required this.userId,
      required this.userEmail,
      required this.userName,
      super.key});

  @override
  _AssignTipsPageState createState() => _AssignTipsPageState();
}

class _AssignTipsPageState extends State<AssignTipsPage> {
  String selectedTip = ''; // To store selected tip type
  TextEditingController resultController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Tips to ${widget.userName}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added ScrollView to avoid overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign tips to ${widget.userName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Tip selection options
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Guided Meditation'),
                    leading: Radio<String>(
                      value: 'Guided Meditation',
                      groupValue: selectedTip,
                      onChanged: (value) {
                        setState(() {
                          selectedTip = value!;
                          if (kDebugMode) {
                            print('Selected Tip: $selectedTip');
                          }
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Breathing Exercise'),
                    leading: Radio<String>(
                      value: 'Breathing Exercise',
                      groupValue: selectedTip,
                      onChanged: (value) {
                        setState(() {
                          selectedTip = value!;
                          if (kDebugMode) {
                            print('Selected Tip: $selectedTip');
                          }
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Mindfulness Tips'),
                    leading: Radio<String>(
                      value: 'Mindfulness Tips',
                      groupValue: selectedTip,
                      onChanged: (value) {
                        setState(() {
                          selectedTip = value!;
                          if (kDebugMode) {
                            print('Selected Tip: $selectedTip');
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // TextField for result input
              TextField(
                controller: resultController,
                decoration: const InputDecoration(
                  labelText: 'Result/Content of the Tip',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (selectedTip.isNotEmpty &&
                      resultController.text.isNotEmpty) {
                    if (kDebugMode) {
                      print("Assigning tip to user...");
                    }
                    // Prepare the Tip object with userId and email
                    Tip newTip = Tip(
                      userEmail: widget.userEmail, // Use email from widget
                      userId: widget.userId, // Pass userId from widget
                      type: selectedTip,
                      result: resultController.text,
                    );

                    await assignTipToUser(
                        newTip); // Assign selected tip with result
                    Navigator.pop(context); // Go back after assigning the tip
                  } else {
                    if (kDebugMode) {
                      print("Form validation failed: Tip or result missing.");
                    }
                    Get.snackbar(
                      'Error',
                      'Please select a tip and enter a result.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Assign Tip'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to assign a tip to a specific user by ID and email
  Future<void> assignTipToUser(Tip tip) async {
    try {
      if (kDebugMode) {
        print("Sending POST request to assign tip...");
      }
      final response = await http.post(
        Uri.parse(
            '${AppConstants.assessmentsUrl}?email=${tip.userEmail}'), // Post to assessments using email
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user": tip.userId, // Pass user ID
          "type": tip.type,
          "result": tip.result,
        }),
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Tip successfully assigned to ${widget.userName}.');
        }
        Get.snackbar(
          'Success',
          'Tip assigned to ${widget.userName}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        if (kDebugMode) {
          print('Failed to assign tip. Status Code: ${response.statusCode}');
        }
        Get.snackbar(
          'Error',
          'Failed to assign tip. Try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning tip: $e');
      }
    }
  }
}
