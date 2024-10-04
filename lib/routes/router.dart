import 'package:calmspace/views/auth_pages/forgot_page.dart';
import 'package:calmspace/views/auth_pages/therapist_login_page.dart';
import 'package:calmspace/views/auth_pages/user_login_page.dart';
import 'package:calmspace/views/auth_pages/signup_page.dart';
import 'package:calmspace/views/home_pages/therapist_home_page.dart';
import 'package:calmspace/views/home_pages/user_home_page.dart';
import 'package:calmspace/views/map_pages/google_map_screen.dart';
import 'package:calmspace/views/profile_pages/therapist_profile_page.dart';
import 'package:calmspace/views/profile_pages/user_profile_page.dart';
import 'package:calmspace/views/role_seletion_page.dart';
import 'package:calmspace/views/chat_pages/therapist_chat_page.dart';
import 'package:calmspace/views/setiings_pages/user_settings_page.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/setiings_pages/therapist_settings_page.dart';

class AppRouter {
  static List<GetPage> routes = [
    GetPage(name: '/role-selection', page: () => const RoleSelectionPage()),
    GetPage(name: '/user-login', page: () => const UserLoginPage()),
    GetPage(name: '/therapist-login', page: () => TherapistLoginPage()),
    GetPage(name: '/signup', page: () => SignUpPage()),
    GetPage(name: '/forgot-password', page: () => const ForgotPage()),
    GetPage(name: '/user-homepage', page: () => const UserHomePage()),
    GetPage(name: '/therapist-homepage', page: () => const TherapistHomePage()),
    GetPage(name: '/user-settings', page: () => const UserSettingsPage()),
    GetPage(name: '/therapist-settings', page: () => const TherapistSettingsPage()),
    GetPage(name: '/therapist-chat', page: () => const TherapistChatPage()),
    GetPage(name: '/user-chat', page: () => const TherapistChatPage()),
    GetPage(name: '/user-profile', page: () => const UserProfilePage()),
    GetPage(name: '/therapist-profile', page: () => const TherapistProfilePage()),
    // GetPage(name: '/therapist-map', page: () => const TherapistMapScreen()),
    // GetPage(name: '/user-map', page: () => const UserMapScreen()),
    GetPage(name: '/map', page: () => GoogleMapScreen()), // Ensure this is a function
  ];

  static void initRoutes(SharedPreferences prefs) {
    Get.put<SharedPreferences>(prefs);
  }
}
