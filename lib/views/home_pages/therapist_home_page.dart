import 'package:calmspace/views/content_page.dart';
import 'package:calmspace/views/navbar.dart';
import 'package:calmspace/views/profile_pages/therapist_profile_page.dart';
import 'package:calmspace/views/tips_pages/therapist_tips_page.dart';
import 'package:cuberto_bottom_bar/internal/tab_data.dart';
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

    // Listen for changes in authentication state (user login/logout)
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          this.user = user; // Refresh user data
        });
      }
    });

    user = FirebaseAuth.instance.currentUser; // Initial user
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            currentLocation = "Location permissions are denied";
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place =
          placemarks.isNotEmpty ? placemarks[0] : const Placemark();

      if (mounted) {
        setState(() {
          currentLocation = "${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentLocation = "Failed to get location";
        });
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.jumpToPage(index);
    }
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
      body: PageView(
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
          TherapistTipsPage(),
          const ContentPage(),
          TherapistProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        tabs: [
          TabData(iconData: Icons.home, title: 'Home'),
          TabData(iconData: Icons.tips_and_updates, title: 'Tips'),
          TabData(iconData: Icons.library_books, title: 'Content'),
          TabData(iconData: Icons.person, title: 'Profile'),
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
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFFF3B8B5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user?.photoURL ??
                'https://via.placeholder.com/150'), // Default photo URL if null
            radius: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user?.displayName ?? 'Therapist Name', // Default name if null
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
