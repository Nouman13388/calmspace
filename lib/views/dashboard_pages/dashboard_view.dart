import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_model.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardView({super.key}) {
    // Fetch health data and appointments during initialization
    controller.fetchHealthData();
    // controller.fetchAppointments('userRole', 'userName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Mood Over Time",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Obx(() {
              if (controller.healthDataList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return _buildMoodChart();
              }
            }),
            const SizedBox(height: 20),
            _buildHealthDataSection(),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.appointmentList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No upcoming appointments."),
                );
              } else {
                return _buildUpcomingAppointment(controller.appointmentList.first);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    final moodData = controller.getChartData();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: moodData
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value[1]))
                  .toList(),
              isCurved: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDataSection() {
    return Obx(() {
      if (controller.healthDataList.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Health Data",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...controller.healthDataList.map((healthData) => _buildHealthDataCard(healthData)).toList(),
            ],
          ),
        );
      }
    });
  }

  Widget _buildHealthDataCard(HealthData healthData) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mood: ${healthData.mood}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Symptoms: ${healthData.symptoms}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text("Recorded At: ${healthData.createdAt.toLocal().toString()}", style: const TextStyle(fontSize: 14)), // Format as needed
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointment(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Appointment:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Status: ${appointment.status}", style: const TextStyle(fontSize: 14)),
            Text("Start Time: ${appointment.startTime}", style: const TextStyle(fontSize: 14)),
            Text("End Time: ${appointment.endTime}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/appointments');
              },
              child: const Text("View All Appointments"),
            ),
          ],
        ),
      ),
    );
  }
}
