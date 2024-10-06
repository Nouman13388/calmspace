// File: lib/views/home_pages/therapist_home_page.dart

import 'package:calmspace/views/map_pages/google_map_screen.dart';
import 'package:calmspace/views/profile_pages/therapist_profile_page.dart';
import 'package:calmspace/views/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../setiings_pages/therapist_settings_page.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();

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

              await prefs.clear();
              await Future.delayed(const Duration(seconds: 1));

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
              greeting: 'Hello, Therapist!',
              featureCards: [
                FeatureCardData(
                  icon: Icons.calendar_today,
                  title: 'Appointments',
                  onTap: () => Get.toNamed('/appointments'),
                ),
                FeatureCardData(
                  icon: Icons.message,
                  title: 'Chat',
                  onTap: () => Get.toNamed('/therapist-chat'),
                ),
                // Add more feature cards as needed
              ],
            ),
            GoogleMapScreen(),
            const TherapistSettingsPage(),
            const TherapistProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
