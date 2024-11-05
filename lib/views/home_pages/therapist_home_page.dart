import 'package:calmspace/views/content_page.dart';
import 'package:calmspace/views/map_pages/google_map_screen.dart';
import 'package:calmspace/views/navbar.dart';
import 'package:calmspace/views/profile_pages/therapist_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import 'home_page.dart';

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({super.key});

  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String currentLocation = "Fetching location...";
  final authController = Get.find<AuthController>();

  User? user; // Firebase user

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    user = FirebaseAuth.instance.currentUser; // Get current user
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = "Location permissions are denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place =
          placemarks.isNotEmpty ? placemarks[0] : const Placemark();

      setState(() {
        currentLocation = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        currentLocation = "Failed to get location";
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
                  currentLocation,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                await authController.logout(prefs);
                Get.back();
                _showLogoutSnackbar();
                Get.offAllNamed('/role-selection');
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
                    icon: Icons.calendar_today,
                    title: 'Appointments',
                    onTap: () => Get.toNamed('/therapist-appointment'),
                  ),
                  FeatureCardData(
                    icon: Icons.message,
                    title: 'Chat',
                    onTap: () => Get.toNamed('/therapist-thread'),
                  ),
                ],
              ),
              GoogleMapScreen(),
              const ContentPage(),
              TherapistProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildDrawerHeader(),
              _buildDrawerItem(
                title: 'Account',
                icon: Icons.account_circle,
                onTap: () => Get.toNamed('/therapist-profile'),
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
        ));
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFFF3B8B5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://via.placeholder.com/150'),
            radius: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user?.displayName ?? 'Therapist Name',
              style: const TextStyle(color: Colors.white, fontSize: 20),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
