import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'initialbinding/initialbinding.dart';
import 'routes/router.dart'; // Your router file
import 'firebase_options.dart'; // Firebase options
import 'utils/themes.dart'; // Custom theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before running the app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebase initialization

  // Initialize Shared Preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  AppRouter.initRoutes(prefs); // Initialize GetX with SharedPreferences

  runApp(const MyApp());
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
