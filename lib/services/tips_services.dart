import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/tips_model.dart';

class TipService {
  // Method to post a Tip
  Future<bool> postTip(Tip tip) async {
    final response = await http.post(
      Uri.parse(AppConstants.assessmentsUrl), // Endpoint updated for tips
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(tip.toJson()),
    );

    if (response.statusCode == 201) {
      // Successfully posted
      return true;
    } else {
      // Handle error
      if (kDebugMode) {
        print('Failed to post tip: ${response.statusCode}');
      }
      return false;
    }
  }

  // Method to fetch tips for a specific user
  Future<List<Tip>> fetchTips(int userId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConstants.assessmentsUrl}?user=$userId'), // Endpoint updated for tips
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Tip.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tips');
    }
  }
}
