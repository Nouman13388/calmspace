import 'dart:convert';

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
  var appointments = <Map<String, dynamic>>[].obs; // Appointments data
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

  // Function to fetch all data (patients and appointments)
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

  // Fetch appointments for a selected patient and the logged-in therapist
  Future<void> fetchAppointmentsForPatient(int patientId) async {
    if (therapistId == null) {
      print('Therapist ID is missing.');
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          '${AppConstants.appointmentsUrl}?user_id=$patientId&therapist_id=$therapistId'));

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

        // Display Patients and their Appointments
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
                  subtitle: Text(patient['email']),
                  onTap: () {
                    // When a patient is tapped, fetch the appointments for that patient and therapist
                    setState(() {
                      appointments.clear(); // Clear previous appointments
                    });
                    // Pass patient['id'] instead of patient['email']
                    fetchAppointmentsForPatient(patient['id']);
                  },
                ),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Appointments for the selected patient',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              // Displaying appointments for the selected patient
              if (appointments.isEmpty)
                const Center(child: Text('No appointments available.'))
              else
                // Displaying the appointments using Cards
                for (var appointment in appointments)
                  Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(
                        Icons.schedule,
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                      title: Text(
                        'Appointment ID: ${appointment['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Start: ${appointment['start_time']}'),
                          Text('End: ${appointment['end_time']}'),
                          Text('Status: ${appointment['status']}'),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}
