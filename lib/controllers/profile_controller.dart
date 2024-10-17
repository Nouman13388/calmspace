// // controllers/profile_controller.dart
// import 'package:get/get.dart';
// import '../services/api_service.dart';
//
// class ProfileController extends GetxController {
//   final ApiService apiService = ApiService();
//
//   void updateProfile(Map<String, dynamic> profileData) async {
//     try {
//       // Send updated profile data to backend
//       await apiService.updateProfile(profileData);
//       Get.snackbar('Success', 'Profile updated successfully');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to update profile');
//     }
//   }
// }
