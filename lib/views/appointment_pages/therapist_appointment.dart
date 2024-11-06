import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';

class TherapistAppointmentPage extends StatefulWidget {
  const TherapistAppointmentPage({super.key});

  @override
  _TherapistAppointmentPageState createState() =>
      _TherapistAppointmentPageState();
}

class _TherapistAppointmentPageState extends State<TherapistAppointmentPage> {
  var patients = <Map<String, dynamic>>[].obs; // Patients data
  var appointments = <Map<String, dynamic>>[].obs; // Appointments data
  var isLoading = true.obs; // Loading status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients and Appointments'),
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
                  'Patients', // Replaced "Users" with "Patients"
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Displaying patients
              for (var patient in patients)
                ListTile(
                  title: Text(patient['name']),
                  subtitle: Text(patient['email']),
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

  // Function to fetch all data (patients and appointments)
  Future<void> fetchData() async {
    isLoading(true); // Set loading to true before fetching

    // Fetch Users and Appointments concurrently
    await Future.wait([
      fetchPatients(), // Fetch patients
      fetchAppointments(
          'victor@gmail.com'), // Fetch appointments for a specific patient
    ]);

    isLoading(false); // Set loading to false after fetching
  }

  // Fetch patients from the API
  Future<void> fetchPatients() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));

      if (response.statusCode == 200) {
        List<dynamic> fetchedPatients = jsonDecode(response.body);
        // Explicitly cast to List<Map<String, dynamic>>
        patients.value = List<Map<String, dynamic>>.from(fetchedPatients);
        print('Patients fetched:');
        fetchedPatients.forEach((patient) {
          print('Patient: ${patient['name']} (${patient['email']})');
        });
      } else {
        print('Failed to fetch patients. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  // Fetch appointments for a logged-in patient (using a static email for now)
  Future<void> fetchAppointments(String patientEmail) async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConstants.appointmentsUrl}?user_email=$patientEmail'));

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
