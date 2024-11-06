import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For formatting date and time

import '../../controllers/booking_controller.dart'; // Import the BookingController

class BookingPage extends StatelessWidget {
  final int userId;
  final int therapistId;
  final String userEmail;
  final String therapistEmail;

  // Initialize the controller
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
        title: const Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Start DateTime Picker
            ListTile(
              title: const Text('Start Time'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
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
                          true, pickedDate, pickedTime);
                    }
                  }
                },
              ),
            ),
            Obx(() {
              if (bookingController.selectedStartDateTime.value != null) {
                return Text(
                  'Start Time: ${DateFormat('dd/MM/yyyy').format(bookingController.selectedStartDateTime.value!)} - ${DateFormat('HH:mm').format(bookingController.selectedStartDateTime.value!)}',
                  style: TextStyle(fontSize: 16),
                );
              }
              return SizedBox.shrink();
            }),
            const SizedBox(height: 20),

            // End DateTime Picker
            ListTile(
              title: const Text('End Time'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
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
                          false, pickedDate, pickedTime);
                    }
                  }
                },
              ),
            ),
            Obx(() {
              if (bookingController.selectedEndDateTime.value != null) {
                return Text(
                  'End Time: ${DateFormat('dd/MM/yyyy').format(bookingController.selectedEndDateTime.value!)} - ${DateFormat('HH:mm').format(bookingController.selectedEndDateTime.value!)}',
                  style: TextStyle(fontSize: 16),
                );
              }
              return SizedBox.shrink();
            }),
            const SizedBox(height: 40),

            // Book Appointment Button
            ElevatedButton(
              onPressed: () {
                bookingController.bookAppointment(
                  userId,
                  therapistId,
                  userEmail,
                  therapistEmail,
                );
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
