import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/dashboard_model.dart';

class ApiService {
  Future<List<HealthData>> fetchHealthData() async {
    final response = await http.get(Uri.parse(AppConstants.healthDataUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("Fetched Health Data: $jsonData");
      return jsonData.map((data) => HealthData.fromMap(data)).toList();
    } else {
      throw Exception('Failed to load health data');
    }
  }

  Future<List<Appointment>> fetchAppointments(String role, String name) async {
    final response = await http.get(Uri.parse('${AppConstants.appointmentsUrl}$role/$name'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("Fetched Appointments: $jsonData");
      return jsonData.map((data) => Appointment.fromJson(data)).toList(); // Use fromJson for consistency
    } else {
      throw Exception('Failed to load appointments');
    }
  }
}
