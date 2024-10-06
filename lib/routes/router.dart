// app_router.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content_page.dart';
import '../views/auth_pages/forgot_page.dart';
import '../views/auth_pages/signup_page.dart';
import '../views/auth_pages/therapist_login_page.dart';
import '../views/auth_pages/user_login_page.dart';
import '../views/chat_pages/therapist_chat_page.dart';
import '../views/chat_pages/user_chat_page.dart';
import '../views/home_pages/therapist_home_page.dart';
import '../views/home_pages/user_home_page.dart';
import '../views/map_pages/google_map_screen.dart';
import '../views/profile_pages/therapist_profile_page.dart';
import '../views/profile_pages/user_profile_page.dart';
import '../views/role_seletion_page.dart';
import '../views/setiings_pages/therapist_settings_page.dart';
import '../views/setiings_pages/user_settings_page.dart';


class AppRouter {
  static List<GetPage> routes = [
    GetPage(name: '/role-selection', page: () => const RoleSelectionPage()),
    GetPage(name: '/user-login', page: () => UserLoginPage()),
    GetPage(name: '/therapist-login', page: () => TherapistLoginPage()),
    GetPage(name: '/signup', page: () => SignUpPage()),
    GetPage(name: '/forgot-password', page: () => const ForgotPage()),
    GetPage(name: '/user-homepage', page: () => const UserHomePage()),
    GetPage(name: '/therapist-homepage', page: () => const TherapistHomePage()),
    GetPage(name: '/user-settings', page: () => const UserSettingsPage()),
    GetPage(name: '/therapist-settings', page: () => const TherapistSettingsPage()),
    GetPage(name: '/therapist-chat', page: () => const TherapistChatPage()),
    GetPage(name: '/user-chat', page: () => const UserChatPage()),
    GetPage(name: '/user-profile', page: () => const UserProfilePage()),
    GetPage(name: '/therapist-profile', page: () => const TherapistProfilePage()),
    GetPage(name: '/map', page: () => GoogleMapScreen()),
    GetPage(name: '/content-page', page: () => const ContentPage()),
  ];

  static void initRoutes(SharedPreferences prefs) {
    Get.put<SharedPreferences>(prefs);
  }
}
