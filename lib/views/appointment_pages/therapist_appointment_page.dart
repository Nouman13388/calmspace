import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/appointment_controller.dart';
import '../../models/dashboard_model.dart';

class TherapistAppointmentPage extends StatefulWidget {
  final String therapistName;

  const TherapistAppointmentPage({super.key, required this.therapistName});

  @override
  _TherapistAppointmentPageState createState() => _TherapistAppointmentPageState();
}

class _TherapistAppointmentPageState extends State<TherapistAppointmentPage> {
  final AppointmentController _controller = Get.put(AppointmentController());
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _controller.fetchAppointments('therapist', widget.therapistName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapist Appointments"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2022),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              List<Appointment> filteredAppointments = _controller.appointments
                  .where((appointment) => appointment.status == "Upcoming" && appointment.therapist == widget.therapistName)
                  .toList();

              return ListView.builder(
                itemCount: filteredAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = filteredAppointments[index];
                  return _buildAppointmentCard(appointment);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          appointment.status == "Upcoming" ? Icons.access_time : Icons.check_circle,
          color: appointment.status == "Upcoming" ? Colors.blue : Colors.green,
        ),
        title: Text(
          "${appointment.user} at ${DateTime.parse(appointment.startTime).hour}:${DateTime.parse(appointment.startTime).minute}",
        ),
        subtitle: Text("Status: ${appointment.status}"),
        trailing: appointment.status == "Upcoming"
            ? ElevatedButton(
          onPressed: () {
            _controller.completeAppointment(appointment);
          },
          child: const Text("Mark Completed"),
        )
            : null,
      ),
    );
  }
}
