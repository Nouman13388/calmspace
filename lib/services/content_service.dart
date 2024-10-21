import 'dart:convert';
import 'package:get/get.dart';
import '../models/content.dart';
import '../constants/app_constants.dart';

class ContentService extends GetConnect {
  // Fetch content from ArticleUrl
  Future<List<MentalHealthContent>> fetchContentFromArticle() async {
    final response = await get(AppConstants.articlesUrl);
    if (response.statusCode == 200) {
      final jsonResponse = response.body[0]; // Get the first element
      final List<dynamic> contentList = jsonResponse['content']; // Extract the content list
      return contentList
          .map((data) => MentalHealthContent.fromMap(data))
          .toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
