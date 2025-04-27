import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/application.dart';

class ApplicationService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your actual API URL

  // Get all applications for a user
  Future<List<Application>> getUserApplications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/applications'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers (e.g., authentication token)
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Get application details
  Future<Application> getApplicationDetails(String applicationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/applications/$applicationId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        return Application.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load application details');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/applications/$applicationId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update application status');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Submit new application
  Future<Application> submitApplication(Application application) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/applications'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
        body: json.encode(application.toJson()),
      );

      if (response.statusCode == 201) {
        return Application.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to submit application');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Get chat messages for an application
  Future<List<Map<String, dynamic>>> getChatMessages(String applicationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/applications/$applicationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Send a chat message
  Future<void> sendChatMessage(String applicationId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/applications/$applicationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
        body: json.encode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }
} 