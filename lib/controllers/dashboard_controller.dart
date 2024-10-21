import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService apiService = ApiService();
  var healthDataList = <HealthData>[].obs;
  var appointmentList = <Appointment>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHealthData();
    fetchAppointments('userRole', 'userName'); // Replace with actual role and name
  }

  Future<void> fetchHealthData() async {
    try {
      healthDataList.value = await apiService.fetchHealthData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load health data: $e');
    }
  }

  Future<void> fetchAppointments(String role, String name) async {
    try {
      appointmentList.value = await apiService.fetchAppointments(role, name);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: $e');
    }
  }

  List<List<double>> getChartData() {
    return healthDataList.map((data) {
      return [data.id.toDouble(), moodToValue(data.mood)];
    }).toList();
  }

  double moodToValue(String mood) {
    switch (mood) {
      case "Happy":
        return 5.0;
      case "Anxious":
        return 3.0;
      case "Sad":
        return 1.0;
      default:
        return 0.0;
    }
  }
}
