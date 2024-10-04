import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../controllers/google_map_controller.dart'; // Adjust the import path as necessary

class GoogleMapScreen extends StatelessWidget {
  final MyGoogleMapController _controller = Get.put(MyGoogleMapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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
            // Animate the camera to the user's location if available
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
    );
  }
}
