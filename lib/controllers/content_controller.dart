import 'package:get/get.dart';
import '../models/mental_health_content_model.dart';
import '../services/content_service.dart';

class ContentController extends GetxController {
  var contentList = <MentalHealthContent>[].obs; // Observable for content list
  var isLoading = false.obs; // Observable for loading state

  final ContentService contentService =
      Get.put(ContentService()); // Instance of ContentService

  @override
  void onInit() {
    super.onInit();
    fetchContent(); // Fetch content when controller is initialized
  }

  // Method to fetch content from ArticleUrl
  Future<void> fetchContent() async {
    try {
      isLoading(true); // Start loading
      contentList.value = await contentService
          .fetchContentFromArticle(); // Fetch data from ArticleUrl
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("Error fetching content: $e"); // Log error to the terminal
    } finally {
      isLoading(false); // Stop loading
    }
  }
}
