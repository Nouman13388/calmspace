import 'dart:convert';

import 'package:calmspace/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';

class UserTipsPage extends StatefulWidget {
  const UserTipsPage({super.key});

  @override
  _UserTipsPageState createState() => _UserTipsPageState();
}

class _UserTipsPageState extends State<UserTipsPage> {
  var assessmentData =
      <Map<String, dynamic>>[].obs; // Holds parsed assessment data
  var isLoading = true.obs; // Loading status

  final userController = Get.find<UserController>();

  int? loggedInUserId; // Will hold the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize data
  Future<void> _initializeData() async {
    try {
      loggedInUserId = await userController.getLoggedInUserId();

      if (loggedInUserId != null) {
        fetchAssessmentData();
      } else {
        Get.snackbar(
          'Error',
          'Please log in to view assessment data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  // Fetch assessments from the API
  Future<void> fetchAssessmentData() async {
    isLoading(true); // Set loading to true before fetching
    try {
      final response = await http.get(
        Uri.parse(AppConstants.assessmentsUrl + '?user=$loggedInUserId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedData = jsonDecode(response.body);
        assessmentData.value = List<Map<String, dynamic>>.from(fetchedData);
        print('Assessment data fetched successfully.');
      } else {
        print(
            'Failed to fetch assessments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assessments: $e');
    } finally {
      isLoading(false); // Set loading to false after fetching
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Tips'),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Categorize the data
        final guidedMeditation = assessmentData
            .where((item) => item['type'] == 'Guided Meditation')
            .toList();
        final breathingExercises = assessmentData
            .where((item) =>
                item['type'] == 'Breathing Exercise') // Updated to match data
            .toList();
        final mindfulnessTips = assessmentData
            .where((item) => item['type'] == 'Mindfulness Tips')
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySection('Guided Meditation', guidedMeditation),
              _buildCategorySection('Breathing Exercises', breathingExercises),
              _buildCategorySection('Mindfulness Tips', mindfulnessTips),
            ],
          ),
        );
      }),
    );
  }

  // Build a category section with a title and items
  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const Text(
            'No tips available.',
            style: TextStyle(color: Colors.grey),
          )
        else
          ...items.map((item) => _buildCard(item)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Build a card for an individual assessment item
  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['type'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item['result'] ?? 'No result available',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              'Created at: ${item['created_at']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
