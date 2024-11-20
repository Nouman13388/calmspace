import 'package:calmspace/views/content_page.dart';
import 'package:calmspace/views/dashboard_pages/dashboard_view.dart';
import 'package:calmspace/views/navbar.dart';
import 'package:cuberto_bottom_bar/internal/tab_data.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_profile_controller.dart'; // Import UserProfileController
import '../profile_pages/user_profile_page.dart';
import 'home_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final User? user = FirebaseAuth.instance.currentUser; // Get current user
  final authController = Get.find<AuthController>();
  final userProfileController =
      Get.find<UserProfileController>(); // Instance of UserProfileController

  String currentLocation = "Fetching location..."; // To store city and country

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch location when the page loads
  }

  // Method to fetch the current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Handle denied forever
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = "Location permissions are denied";
        });
        return;
      }

      // Get the current position of the user
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get placemarks (city and country) based on the position
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        currentLocation =
            "${place.locality}, ${place.country}"; // Update location
      });
    } catch (e) {
      setState(() {
        currentLocation = "Failed to get location"; // Handle error
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _showLogoutSnackbar() {
    Get.snackbar(
      'Success',
      'Logged out successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SharedPreferences prefs = Get.find<SharedPreferences>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                currentLocation, // Display the city and country
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(
                userProfileController.profilePicture.value.isNotEmpty
                    ? userProfileController.profilePicture.value
                    : user?.photoURL ?? 'https://via.placeholder.com/150',
              ), // User profile picture
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              await authController
                  .logout(prefs); // Call logout from AuthController

              Get.back();
              _showLogoutSnackbar();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomePage(
              featureCards: [
                FeatureCardData(
                  icon: Icons.chat,
                  title: 'Chat',
                  onTap: () => Get.toNamed('/user-thread'),
                ),
                FeatureCardData(
                  icon: Icons.calendar_month_outlined,
                  title: 'Book Appointment',
                  onTap: () => Get.toNamed('/user-appointment'),
                ),
                FeatureCardData(
                  icon: Icons.location_on,
                  title: 'Clinic Locator',
                  onTap: () => Get.toNamed('/map'),
                ),
                FeatureCardData(
                  icon: Icons.assessment,
                  title: 'Assessments',
                  onTap: () => Get.toNamed('/assessment'),
                ),
                FeatureCardData(
                  icon: Icons.tips_and_updates,
                  title: 'Tips',
                  onTap: () => Get.toNamed('/user-tips'),
                ),
                FeatureCardData(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  onTap: () => Get.toNamed('/feedback'),
                ),
              ],
            ),
            DashboardView(),
            const ContentPage(),
            UserProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        tabs: [
          TabData(
            iconData: Icons.home,
            title: 'Home',
          ),
          TabData(
            iconData: Icons.dashboard,
            title: 'Dashboard',
          ),
          TabData(
            iconData: Icons.article,
            title: 'Content',
          ),
          TabData(
            iconData: Icons.person,
            title: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(),
            _buildDrawerItem(
              title: 'Account',
              icon: Icons.account_circle,
              onTap: () => Get.toNamed('/user-profile'),
            ),
            _buildDrawerItem(
              title: 'Notification Preferences',
              icon: Icons.notifications,
              onTap: () => Get.toNamed('/notification-preferences'),
            ),
            _buildDrawerItem(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip,
              onTap: () => Get.toNamed('/privacy-policy'),
            ),
            _buildDrawerItem(
              title: 'Terms of Service',
              icon: Icons.description,
              onTap: () => Get.toNamed('/terms-of-service'),
            ),
            _buildDrawerItem(
              title: 'Emergency Support',
              icon: Icons.support,
              onTap: () => Get.toNamed('/emergency'),
            ),
            const Divider(),
            _buildDrawerItem(
              title: 'Logout',
              icon: Icons.exit_to_app,
              onTap: () async {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                await authController.logout(prefs);
                Get.back();
                _showLogoutSnackbar();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Color(0xFFF3B8B5)),
      child: Obx(() {
        return Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                userProfileController.profilePicture.value.isNotEmpty
                    ? userProfileController.profilePicture.value
                    : user?.photoURL ?? 'https://via.placeholder.com/150',
              ),
              radius: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                userProfileController.username.value.isNotEmpty
                    ? userProfileController.username.value
                    : 'User Name',
                style: const TextStyle(color: Colors.white, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
