import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../controllers/google_map_controller.dart'; // Adjust the import path as necessary

class GoogleMapScreen extends StatelessWidget {
  final MyGoogleMapController _controller = Get.put(MyGoogleMapController());

  GoogleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clinic Locator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Add action for info button
              Get.snackbar(
                'Info',
                'Find clinics near your location.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orangeAccent,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        }
        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 15,
          ),
          markers: _controller.markers.toSet(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController mapController) {
            if (_controller.currentLocation.isNotEmpty) {
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      _controller.currentLocation['latitude']!,
                      _controller.currentLocation['longitude']!,
                    ),
                    zoom: 15,
                  ),
                ),
              );
            }
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Refresh current location and clinic data
          await _controller.getCurrentLocation();
          await _controller.fetchClinics(); // Fetch clinics after refreshing location
          Get.snackbar(
            'Data Refreshed',
            'Your location and clinics have been refreshed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),

          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // Moved to left side
    );
  }
}
