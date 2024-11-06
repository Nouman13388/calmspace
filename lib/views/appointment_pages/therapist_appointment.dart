import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';

class TherapistAppointmentPage extends StatelessWidget {
  TherapistAppointmentPage({super.key});

  // Rx variables to store data
  var users = <Map<String, dynamic>>[].obs;
  var appointments = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs; // Loading status for the page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users and Appointments'),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Users',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Displaying users
              for (var user in users)
                ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Appointments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Displaying appointments
              for (var appointment in appointments)
                Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: ListTile(
                    title: Text('Appointment ID: ${appointment['id']}'),
                    subtitle: Text(
                      'Start: ${appointment['start_time']} \nEnd: ${appointment['end_time']} \nStatus: ${appointment['status']}',
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Fetch data when button is pressed
          fetchData();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Function to fetch all data (users and appointments)
  Future<void> fetchData() async {
    isLoading(true); // Set loading to true before fetching

    // Fetch Users
    await fetchUsers();

    // Fetch Appointments for a specific user
    await fetchAppointments('victor@gmail.com');

    isLoading(false); // Set loading to false after fetching
  }

  // Fetch users from the API
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));

      if (response.statusCode == 200) {
        List<dynamic> fetchedUsers = jsonDecode(response.body);
        // Explicitly cast to List<Map<String, dynamic>>
        users.value = List<Map<String, dynamic>>.from(fetchedUsers);
        print('Users fetched:');
        fetchedUsers.forEach((user) {
          print('User: ${user['name']} (${user['email']})');
        });
      } else {
        print('Failed to fetch users. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Fetch appointments for a logged-in user (using a static email for now)
  Future<void> fetchAppointments(String userEmail) async {
    try {
      final response = await http.get(
          Uri.parse('${AppConstants.appointmentsUrl}?user_email=$userEmail'));

      if (response.statusCode == 200) {
        List<dynamic> fetchedAppointments = jsonDecode(response.body);
        // Explicitly cast to List<Map<String, dynamic>>
        appointments.value =
            List<Map<String, dynamic>>.from(fetchedAppointments);
        print('Appointments fetched:');
        fetchedAppointments.forEach((appointment) {
          print('Appointment ID: ${appointment['id']}');
          print('Start: ${appointment['start_time']}');
          print('End: ${appointment['end_time']}');
          print('Therapist ID: ${appointment['therapist']}');
          print('Status: ${appointment['status']}');
        });
      } else {
        print(
            'Failed to fetch appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }
}
