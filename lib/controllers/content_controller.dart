import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/content.dart';
import '../services/api_service.dart';

class ContentController extends GetxController {
  var contentList = <MentalHealthContent>[].obs; // Observable for content list
  var isLoading = false.obs; // Observable for loading state

  final ContentService contentService = Get.put(ContentService());

  @override
  void onInit() {
    super.onInit();
    fetchContent(); // Fetch content when controller is initialized
  }

  Future<void> fetchContent() async {
    try {
      isLoading(true); // Start loading
      final articles = await contentService.fetchContentFromArticle(); // Fetch articles
      contentList.value = articles; // Update content list
      if (kDebugMode) {
        print('Fetched ${contentList.length} articles');
      } // Debug output
    } catch (e) {
      Get.snackbar("Error", e.toString());
      if (kDebugMode) {
        print("Error fetching content: $e");
      } // Log error
    } finally {
      isLoading(false); // Stop loading
    }
  }
}
