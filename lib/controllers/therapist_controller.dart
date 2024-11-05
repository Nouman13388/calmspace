import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class TherapistController extends GetxController {
  var therapists = <Therapist>[].obs;

  // Fetch therapists from the API
  Future<void> fetchTherapists() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.professionalsUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        therapists.value = data.map((e) => Therapist.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load therapists');
      }
    } catch (e) {
      print("Error fetching therapists: $e");
    }
  }

  // Get logged-in therapist's ID by matching the email
  Future<int?> getLoggedInTherapistId() async {
    try {
      final firebase_auth.User? firebaseUser =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final loggedInEmail = firebaseUser.email;

        // Find the therapist with the matching email
        final matchedTherapist = therapists.firstWhere(
          (therapist) => therapist.email == loggedInEmail,
          orElse: () => Therapist(
              id: -1, name: '', specialization: '', bio: '', email: ''),
        );

        if (matchedTherapist.id != -1) {
          return matchedTherapist.id; // Return therapist ID if matched
        } else {
          return null; // No therapist found with the logged-in email
        }
      } else {
        return null; // No logged-in user found
      }
    } catch (e) {
      print("Error finding therapist by email: $e");
      return null;
    }
  }
}

class Therapist {
  final int id;
  final String email; // Added email to the model
  final String name;
  final String specialization;
  final String bio;

  Therapist({
    required this.id,
    required this.email,
    required this.name,
    required this.specialization,
    required this.bio,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json['id'],
      email: json['email'], // Parsing email from the backend response
      name: json['name'],
      specialization: json['specialization'] ?? 'Not specified',
      bio: json['bio'] ?? 'No bio available.',
    );
  }
}
