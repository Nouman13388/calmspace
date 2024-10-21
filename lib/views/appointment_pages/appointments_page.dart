import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';

class AppointmentsView extends StatelessWidget {
  final DashboardController controller = Get.find();

  AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.appointmentList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: controller.appointmentList.length,
            itemBuilder: (context, index) {
              final appointment = controller.appointmentList[index];
              return ListTile(
                title: Text("Appointment ${appointment.id}"),
                subtitle: Text(
                  "Status: ${appointment.status}\n"
                      "Start Time: ${appointment.startTime}\n"
                      "End Time: ${appointment.endTime}",
                ),
              );
            },
          );
        }
      }),
    );
  }
}
