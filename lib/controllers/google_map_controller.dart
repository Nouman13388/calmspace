import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Needed for Marker and LatLng
import 'location_controller.dart'; // Adjust the import path as necessary

class MyGoogleMapController extends GetxController {
  var isLoading = true.obs;
  var currentLocation = <String, double>{}.obs;
  final markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    currentLocation.value = await LocationService.getLocation() ?? {};
    if (currentLocation.isNotEmpty) {
      updateMarkers();
    }
    isLoading.value = false;
  }

  void updateMarkers() {
    if (currentLocation.isNotEmpty) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            currentLocation['latitude']!,
            currentLocation['longitude']!,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
  }
}
