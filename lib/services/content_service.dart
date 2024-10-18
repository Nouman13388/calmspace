import 'dart:convert';
import 'package:get/get.dart';
import '../models/mental_health_content_model.dart';
import '../constants/app_constants.dart'; // Make sure to import your constants file

class ContentService extends GetConnect {
  // Fetch content from ArticleUrl
  Future<List<MentalHealthContent>> fetchContentFromArticle() async {
    final response = await get(AppConstants.articleUrl);
    print('data is: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = response.body;
      return jsonResponse
          .map((data) => MentalHealthContent.fromMap(data))
          .toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
