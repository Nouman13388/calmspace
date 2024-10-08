// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/mental_health_content_model.dart';

class ApiService {
  final String apiUrl = "http://your-django-api-url/api/content"; // Update with your actual URL

  Future<List<MentalHealthContent>> fetchContent() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MentalHealthContent.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load content');
    }
  }

  Future<MentalHealthContent> createContent(String title, String description) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 201) {
      return MentalHealthContent.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create content');
    }
  }

  Future<void> updateContent(MentalHealthContent content) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${content.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(content.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update content');
    }
  }

  Future<void> deleteContent(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete content');
    }
  }
}
