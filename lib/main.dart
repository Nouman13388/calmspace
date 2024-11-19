import 'package:calmspace/controllers/booking_controller.dart';
import 'package:calmspace/controllers/user_controller.dart';
import 'package:calmspace/services/api_service.dart';
import 'package:calmspace/views/video_call_pages/services/rtc_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart'; // Add provider package
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/therapist_controller.dart';
import 'controllers/therapist_profile_controller.dart'; // Keep only the required import
import 'controllers/user_profile_controller.dart';
import 'firebase_options.dart'; // Firebase options
import 'initialbinding/initialbinding.dart';
import 'routes/router.dart'; // Your router file
import 'utils/themes.dart'; // Custom theme

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter is initialized before running the app

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase initialization

  // Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Initialize controllers
  Get.put(UserController()); // Ensure UserController is initialized first
  Get.put(TherapistController()); // TherapistController
  Get.put(ApiService()); // ApiService
  Get.put(BookingController()); // BookingController
  Get.put(
      TherapistProfileController()); // Ensure this is the correct controller used in the app
  Get.put(
      UserProfileController()); // Ensure this is the correct controller used in the app

  AppRouter.initRoutes(prefs); // Initialize GetX with SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        // Add the RTCService provider here
        Provider<RTCService>(
          create: (_) => RTCService(), // Replace with your RTCService
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Calm Space',
      theme: calmSpaceTheme(), // Use the custom theme
      initialRoute: '/role-selection',
      initialBinding: InitialBinding(),
      getPages: AppRouter.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
