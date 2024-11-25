import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';

class PatientAppointmentsPage extends StatefulWidget {
  final int patientId; // Patient's ID
  final int therapistId; // Therapist's ID

  const PatientAppointmentsPage({
    super.key,
    required this.patientId,
    required this.therapistId,
  });

  @override
  _PatientAppointmentsPageState createState() =>
      _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage> {
  var appointments = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  // Fetch appointments for the selected patient and the logged-in therapist
  Future<void> _fetchAppointments() async {
    setState(() {
      isLoading(true);
    });

    try {
      // Fetch appointments using the passed patient ID and therapist ID
      final response = await http.get(Uri.parse(
          '${AppConstants.appointmentsUrl}?user_id=${widget.patientId}&therapist_id=${widget.therapistId}'));

      if (response.statusCode == 200) {
        List<dynamic> fetchedAppointments = jsonDecode(response.body);
        setState(() {
          appointments.value =
              List<Map<String, dynamic>>.from(fetchedAppointments);
        });
      } else {
        print('Failed to fetch appointments.');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    } finally {
      setState(() {
        isLoading(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments for the Patient'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Appointments',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
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
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}
