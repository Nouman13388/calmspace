import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_controller.dart'; // Adjust the import path as necessary
import '../constants/app_constants.dart'; // Import your AppConstants for URLs
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyGoogleMapController extends GetxController {
  var isLoading = true.obs;
  var currentLocation = <String, double>{}.obs;
  final markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation(); // Fetch current location when initialized
    fetchClinics(); // Fetch clinic locations
  }

  @override
  void onClose() {
    super.onClose();
    // Optional: Clear markers here if needed when the controller is disposed
    // markers.clear();
  }

  Future<void> getCurrentLocation() async {
    currentLocation.value = await LocationService.getLocation() ?? {};
    if (currentLocation.isNotEmpty) {
      updateUserMarker(); // Update user marker with the current location
    }
    isLoading.value = false; // Update loading state
  }

  void updateUserMarker() {
    if (currentLocation.isNotEmpty) {
      // Clear only clinic markers, keep user marker
      markers.removeWhere((marker) => marker.markerId.value != 'user_location');

      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            currentLocation['latitude']!,
            currentLocation['longitude']!,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      if (kDebugMode) {
        print('User Location: ${currentLocation['latitude']}, ${currentLocation['longitude']}');
      }
    }
  }

  Future<void> fetchClinics() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.clinicsUrl));
      if (response.statusCode == 200) {
        final List clinics = json.decode(response.body);
        if (kDebugMode) {
          print('Clinics fetched: $clinics');
        }
        updateClinicMarkers(clinics); // Update markers with fetched clinics
      } else {
        if (kDebugMode) {
          print('Failed to load clinics: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching clinics: $e');
      }
    }
  }

  void updateClinicMarkers(List clinics) {
    // Keep the user marker, remove only clinic markers
    markers.removeWhere((marker) => marker.markerId.value != 'user_location');

    for (var clinic in clinics) {
      try {
        double latitude = double.tryParse(clinic['latitude'].toString()) ?? 0.0;
        double longitude = double.tryParse(clinic['longitude'].toString()) ?? 0.0;

        if (latitude != 0.0 && longitude != 0.0) {
          if (kDebugMode) {
            print('Clinic: ${clinic['name']} | Latitude: $latitude, Longitude: $longitude');
          }

          markers.add(
            Marker(
              markerId: MarkerId(clinic['id'].toString()),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: clinic['name'],
                snippet: clinic['address'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        } else {
          if (kDebugMode) {
            print('Invalid coordinates for clinic: ${clinic['name']}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing clinic data: $e');
        }
      }
    }
  }
}
