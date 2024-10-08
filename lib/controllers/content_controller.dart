import 'package:get/get.dart';
import '../models/mental_health_content_model.dart';
import '../services/api_service.dart';

class ContentController extends GetxController {
  final ApiService _apiService = ApiService();
  var contentList = <MentalHealthContent>[].obs; // Observable list

  @override
  void onInit() {
    fetchContent();
    super.onInit();
  }

  Future<void> fetchContent() async {
    try {
      contentList.value = await _apiService.fetchContent(); // Fetching content from API
    } catch (e) {
      // Handle error
      print("Error fetching content: $e");
    }
  }

  Future<void> addContent(String title, String description) async {
    try {
      final newContent = await _apiService.createContent(title, description);
      contentList.add(newContent); // Add new content to the list
    } catch (e) {
      // Handle error
      print("Error adding content: $e");
    }
  }

  Future<void> updateContent(MentalHealthContent content) async {
    try {
      await _apiService.updateContent(content);
      int index = contentList.indexWhere((c) => c.id == content.id);
      if (index != -1) {
        contentList[index] = content; // Update the list
      }
    } catch (e) {
      // Handle error
      print("Error updating content: $e");
    }
  }

  Future<void> deleteContent(int id) async {
    try {
      await _apiService.deleteContent(id);
      contentList.removeWhere((content) => content.id == id); // Remove from the list
    } catch (e) {
      // Handle error
      print("Error deleting content: $e");
    }
  }
}
