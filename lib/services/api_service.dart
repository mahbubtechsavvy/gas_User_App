import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:user_app/models/user_login_response.dart';

class ApiService {
  // IMPORTANT: Replace with your actual server IP/domain.
  // For Android emulator, use 10.0.2.2 to connect to localhost.
  // For iOS simulator, use localhost or 127.0.0.1.
  static const String _baseUrl = "http://10.0.2.2/your_project_api_folder";

  Future<UserLoginResponse> loginUser(String email, String password) async {
    final Uri loginUrl = Uri.parse('$_baseUrl/user/login.php');

    try {
      final response = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        return UserLoginResponse.fromJson(responseBody);
      } else {
        // The API returned an error status (e.g., 401, 404) or a success status with a failure message
        throw Exception(responseBody['message'] ?? 'Failed to login');
      }
    } on SocketException {
        throw Exception('No Internet connection. Please check your network.');
    } on HttpException {
        throw Exception('Could not find the server. Please check the API URL.');
    } on FormatException {
        throw Exception('Bad response format from the server.');
    } catch (e) {
      // Rethrow other exceptions to be handled by the UI
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Placeholder for fetching services - to be implemented later
  Future<void> getServices() async {
    // Logic for /api/services/list.php will go here
  }
}