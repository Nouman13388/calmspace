import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/booking_controller.dart';
import '../../models/dashboard_model.dart';

class BookingPage extends StatelessWidget {
  final int userId;
  final int therapistId;
  final String userEmail;
  final String therapistEmail;

  final BookingController bookingController = Get.put(BookingController());

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
            // Start Time Picker
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
                        const Text(
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

            // Book Appointment Button
            Obx(() {
              return Center(
                child: ElevatedButton(
                  onPressed: bookingController.isLoading.value
                      ? null // Disable while loading
                      : () async {
                          try {
                            // Validate and check for overlaps
                            bool isOverlapping = await bookingController
                                .checkForOverlappingAppointments(
                                    userId, therapistId);

                            if (isOverlapping) {
                              // Show overlap error
                              Get.snackbar(
                                'Time Slot Unavailable',
                                'This time slot is already booked. Please choose another.',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            // Check if selected time is valid
                            final selectedStartTime =
                                bookingController.selectedStartDateTime.value;
                            if (selectedStartTime != null &&
                                selectedStartTime.isBefore(DateTime.now())) {
                              Get.snackbar(
                                'Invalid Appointment Time',
                                'You cannot book an appointment in the past.',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            // Proceed to book the appointment
                            await bookingController.bookAppointment(
                                userId, therapistId, userEmail, therapistEmail);

                            if (bookingController.isAppointmentBooked.value) {
                              // Show success message
                              Get.snackbar(
                                'Appointment Booked',
                                'Your appointment has been successfully booked!',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } catch (error) {
                            Get.snackbar(
                              'Booking Failed',
                              'An error occurred: $error',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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

            // Display upcoming appointments
            FutureBuilder<List<Appointment>>(
              future: bookingController.fetchAppointmentsFromApi(
                  userId, therapistId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching appointments'));
                }
                if (snapshot.hasData) {
                  List<Appointment> appointments = snapshot.data!;
                  if (appointments.isEmpty) {
                    return const Text('No upcoming appointments.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: appointments.map((appointment) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: const Text('Appointment with Therapist',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            'Start: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.startTime)}\n'
                            'End: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.endTime)}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Text('No appointments available.');
              },
            ),
          ],
        ),
      ),
    );
  }

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
          title: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today,
                color: Colors.deepPurpleAccent),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2025),
              );
              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  bookingController.selectDateTime(
                      isStartTime, pickedDate, pickedTime);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
