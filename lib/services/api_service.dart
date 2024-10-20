// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/content.dart';

class ApiService {
  final String apiUrl = "https://api.nhs.uk/mental-health?api-version=1.0";

  Future<List<MentalHealthContent>> fetchContent() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Ocp-Apim-Subscription-Key':
              'ba52539dd260499198a6c9ee97bef2b1', // Your Primary Key
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MentalHealthContent.fromMap(json)).toList();
      } else {
        print(
            "Error fetching content: ${response.statusCode} - ${response.reasonPhrase}");
        throw Exception('Failed to load content: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Exception in fetchContent: $e");
      throw Exception('Failed to load content');
    }
  }
}
