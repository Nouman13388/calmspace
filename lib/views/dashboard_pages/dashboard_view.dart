import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_model.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardView({super.key}) {
    controller.loadDashboardData(); // Load data on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            _buildScoreAndBadgeInfo(),
            const SizedBox(height: 20),
            _buildHealthDataSection(),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.appointmentList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No latest appointments."),
                );
              } else {
                // Get the latest appointment from the list
                Appointment latestAppointment = controller.appointmentList.last;
                return _buildUpcomingAppointment(latestAppointment);
              }
            }),
          ],
        ),
      ),
    );
  }

  // Display score and badge using icons
  Widget _buildScoreAndBadgeInfo() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.score, color: Colors.blue, size: 30),
                const SizedBox(width: 8),
                Text(
                  "${controller.points.value}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  controller.badge.value.isNotEmpty
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.badge.value.isNotEmpty
                      ? controller.badge.value
                      : "No Badge",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );
    });
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
              ...controller.healthDataList
                  .map((healthData) => _buildHealthDataCard(healthData)),
            ],
          ),
        );
      }
    });
  }

  Widget _buildHealthDataCard(HealthData healthData) {
    // Add 5 hours to the time for display purposes
    DateTime adjustedTime = healthData.createdAt.add(Duration(hours: 8));

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
            Text("Mood: ${healthData.mood}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Symptoms: ${healthData.symptoms}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
                "Recorded At: ${formatDate(adjustedTime)}", // Use adjusted time here
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Display upcoming appointment details
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
              "Latest Booked Appointment:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text("Status: ${appointment.status}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Start Time: ${formatDate(appointment.startTime)}"),
                  Text("End Time: ${formatDate(appointment.endTime)}"),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper function to format DateTime
  String formatDate(DateTime dateTime) {
    return DateFormat.yMMMMd().add_jm().format(dateTime);
  }
}
