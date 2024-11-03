import 'package:calmspace/views/assessment_page.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/appointment_pages/therapist_appointment_page.dart';
import '../views/appointment_pages/user_appointment_page.dart';
import '../views/auth_pages/forgot_page.dart';
import '../views/auth_pages/therapist_login_page.dart';
import '../views/auth_pages/therapist_signup_page.dart';
import '../views/auth_pages/user_login_page.dart';
import '../views/auth_pages/user_signup_page.dart';
import '../views/chat_pages/chat_page.dart';
import '../views/content_page.dart';
import '../views/drawer_item_page.dart';
import '../views/feedback_page.dart';
import '../views/home_pages/therapist_home_page.dart';
import '../views/home_pages/user_home_page.dart';
import '../views/map_pages/google_map_screen.dart';
import '../views/profile_pages/therapist_profile_page.dart';
import '../views/profile_pages/user_profile_page.dart';
import '../views/role_seletion_page.dart';
import '../views/setiings_pages/user_settings_page.dart';

class AppRouter {
  static List<GetPage> routes = [
    GetPage(name: '/role-selection', page: () => const RoleSelectionPage()),
    GetPage(name: '/user-login', page: () => UserLoginPage()),
    GetPage(name: '/therapist-login', page: () => TherapistLoginPage()),
    GetPage(name: '/user-signup', page: () => UserSignUpPage()),
    GetPage(name: '/therapist-signup', page: () => TherapistSignUpPage()),
    GetPage(name: '/forgot-password', page: () => const ForgotPage()),
    GetPage(name: '/user-homepage', page: () => const UserHomePage()),
    GetPage(name: '/therapist-homepage', page: () => const TherapistHomePage()),
    GetPage(name: '/user-settings', page: () => const UserSettingsPage()),
    GetPage(name: '/user-profile', page: () => UserProfilePage()),
    GetPage(name: '/therapist-profile', page: () => TherapistProfilePage()),
    GetPage(name: '/map', page: () => GoogleMapScreen()),
    GetPage(name: '/content-page', page: () => const ContentPage()),
    GetPage(
        name: '/therapist-appointment',
        page: () => const TherapistAppointmentPage(therapistName: '')),
    GetPage(
        name: '/user-appointment',
        page: () => const UserAppointmentPage(userName: '')),
    GetPage(
        name: '/notification-preferences',
        page: () => NotificationPreferencesPage()), // New route
    GetPage(
        name: '/news-preferences',
        page: () => NewsPreferencesPage()), // New route
    GetPage(
        name: '/privacy-policy', page: () => PrivacyPolicyPage()), // New route
    GetPage(
        name: '/terms-of-service',
        page: () => TermsOfServicePage()), // New route
    GetPage(
        name: '/chat-page',
        page: () => ChatPage(
              userId: '1',
              professionalId: '1',
              roomName: '',
            )), // Updated route
    GetPage(name: '/feedback', page: () => FeedbackPage()), // New route
    GetPage(name: '/assessment', page: () => AssessmentPage()), // New route
    GetPage(
        name: '/privacy-policy', page: () => PrivacyPolicyPage()), // New route
    GetPage(
        name: '/notification-preference',
        page: () => NotificationPreferencesPage()), // New route
    GetPage(
        name: '/terms-of-service',
        page: () => TermsOfServicePage()), // New route
    // GetPage(
    //     name: '/emergency', page: () => EmergencySupportPage()),
  ];

  static void initRoutes(SharedPreferences prefs) {
    Get.put<SharedPreferences>(prefs);
  }
}
