import 'dart:convert';

import 'package:calmspace/views/appointment_pages/patient_appointment_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../controllers/therapist_controller.dart';

class TherapistAppointmentPage extends StatefulWidget {
  const TherapistAppointmentPage({super.key});

  @override
  _TherapistAppointmentPageState createState() =>
      _TherapistAppointmentPageState();
}

class _TherapistAppointmentPageState extends State<TherapistAppointmentPage> {
  var patients = <Map<String, dynamic>>[].obs; // Patients data
  var isLoading = true.obs; // Loading status

  // Instance of TherapistController
  final therapistController = Get.find<TherapistController>();

  int? therapistId; // Will hold the therapist's ID

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
    // First, fetch the therapist data
    await therapistController.fetchTherapists();

    // After fetching therapists, get the logged-in therapist's ID
    therapistId = await therapistController.getLoggedInTherapistId();

    if (therapistId != null) {
      // If therapist ID is found, fetch patients
      fetchData();
    } else {
      // If no therapist ID found, show an error message
      print('Therapist ID is missing. Redirecting to login...');
      Get.snackbar(
        'Error',
        'Please log in as a therapist to view appointments.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  // Function to fetch all data (patients)
  Future<void> fetchData() async {
    isLoading(true); // Set loading to true before fetching

    // Fetch Patients
    await fetchPatients();

    isLoading(false); // Set loading to false after fetching
  }

  // Fetch patients from the API
  Future<void> fetchPatients() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.usersUrl));

      if (response.statusCode == 200) {
        List<dynamic> fetchedPatients = jsonDecode(response.body);
        // Filter out the currently logged-in therapist
        fetchedPatients = fetchedPatients.where((patient) {
          return patient['id'] !=
              therapistId; // Exclude the logged-in therapist
        }).toList();

        // Explicitly cast to List<Map<String, dynamic>>
        patients.value = List<Map<String, dynamic>>.from(fetchedPatients);
        print('Patients fetched:');
        fetchedPatients.forEach((patient) {
          print('Patient: ${patient['name']} (${patient['id']})');
        });
      } else {
        print('Failed to fetch patients. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients and Appointments'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        // If loading, show the progress indicator
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display Patients
        return SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Patients',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              // Displaying patients
              for (var patient in patients)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    patient['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${patient['id']}'),
                  onTap: () {
                    // When a patient is tapped, navigate to the PatientAppointmentsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientAppointmentsPage(
                          patientId: patient['id'], // Pass the patient ID
                          therapistId: therapistId!, // Pass the therapist ID
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
