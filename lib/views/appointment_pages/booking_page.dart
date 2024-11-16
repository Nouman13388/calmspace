import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/booking_controller.dart';
import '../../models/dashboard_model.dart';
import '../../services/api_service.dart'; // Assuming ApiService is responsible for fetching appointment data

class BookingPage extends StatelessWidget {
  final int userId;
  final int therapistId;
  final String userEmail;
  final String therapistEmail;

  final BookingController bookingController = Get.put(BookingController());
  final ApiService _apiService =
      Get.put(ApiService()); // API service to fetch data

  BookingPage({
    super.key,
    required this.userId,
    required this.therapistId,
    required this.userEmail,
    required this.therapistEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: const Text('Book Appointment',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateTimePickerSection(context, 'Start Time', true),
            const SizedBox(height: 20),

            // Preview Selected Date and Time
            Obx(() {
              final startDateTime =
                  bookingController.selectedStartDateTime.value;
              final endDateTime = bookingController.selectedEndDateTime.value;
              if (startDateTime != null && endDateTime != null) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Appointment Time:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Start Time: ${DateFormat('dd/MM/yyyy').format(startDateTime)} - ${DateFormat('HH:mm').format(startDateTime)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'End Time: ${DateFormat('dd/MM/yyyy').format(endDateTime)} - ${DateFormat('HH:mm').format(endDateTime)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 40),

            // Book Appointment Button with Loader
            Obx(() {
              return Center(
                child: ElevatedButton(
                  onPressed: bookingController.isLoading.value
                      ? null // Disable button while loading
                      : () async {
                          try {
                            // Check if the selected appointment time is available
                            bool isOverlapping = await bookingController
                                .checkForOverlappingAppointments(
                                    userId, therapistId);

                            if (isOverlapping) {
                              Get.snackbar(
                                'Time Slot Unavailable',
                                'This time slot is already booked. Please choose another.',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              // Check if the selected time is in the past
                              final selectedStartTime =
                                  bookingController.selectedStartDateTime.value;
                              if (selectedStartTime != null &&
                                  selectedStartTime.isBefore(DateTime.now())) {
                                // Show an error if the appointment is in the past
                                Get.snackbar(
                                  'Invalid Appointment Time',
                                  'You cannot book an appointment in the past.',
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                // If no overlap and the time is valid, proceed with booking
                                await bookingController.bookAppointment(
                                  userId,
                                  therapistId,
                                  userEmail,
                                  therapistEmail,
                                );

                                // Provide success feedback
                                Get.snackbar(
                                  'Appointment Booked',
                                  'Your appointment has been successfully booked!',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            }
                          } catch (error) {
                            // Handle errors (e.g., network issues, null data, etc.)
                            print(
                                'Error occurred while booking appointment: $error');
                            Get.snackbar(
                              'Booking Failed',
                              'An error occurred while booking your appointment. Please try again.',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.deepPurpleAccent,
                    elevation: 5,
                  ),
                  child: bookingController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Book Appointment',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              );
            }),

            const SizedBox(height: 40),

            // Optionally, display upcoming or past appointments
            FutureBuilder<List<Appointment>>(
              future: _apiService.fetchAppointments(
                  'User', 'Name'), // Adjust the parameters for your fetch logic
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching appointments'));
                }
                if (snapshot.hasData) {
                  List<Appointment> appointments =
                      snapshot.data!; // Safely cast to List<Appointment>
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Appointments',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.deepPurpleAccent),
                      ),
                      const SizedBox(height: 10),
                      ...appointments.map((appointment) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text('Appointment with Therapist',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              'Start: ${DateFormat('dd/MM/yyyy').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.startTime)}\n'
                              'End: ${DateFormat('dd/MM/yyyy').format(appointment.endTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }
                return const Text('No appointments available');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Reusable date/time picker section with calendar and clock picker
  Widget _buildDateTimePickerSection(
      BuildContext context, String title, bool isStartTime) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today,
                color: Colors.deepPurpleAccent),
            onPressed: () async {
              // First pick the date
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2025),
              );
              if (pickedDate != null) {
                // After date is picked, pick the time
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  // Set the start time
                  bookingController.selectDateTime(
                      isStartTime, pickedDate, pickedTime);

                  // Automatically set the end time to 1.5 hours after the start time
                  bookingController.setEndTimeForStartTime();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
