import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

class AuthService {

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/accounts/register/',
    );

    try {

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      print("REGISTER STATUS => ${response.statusCode}");
      print("REGISTER DATA => $data");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        return data;

      } else {

        throw Exception(data.toString());

      }

    } catch (e) {

      throw Exception("Registration failed: $e");

    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/api/accounts/login/',
    );

    try {

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      print("LOGIN STATUS => ${response.statusCode}");
      print("LOGIN DATA => $data");

      if (response.statusCode == 200) {

        // SAVE TOKEN
        final prefs =
            await SharedPreferences.getInstance();

        await prefs.setString(
          'access',
          data['access'],
        );

        return data;

      } else {

        throw Exception(data.toString());

      }

    } catch (e) {

      throw Exception("Login failed: $e");

    }
  }

  // GET ACCESS TOKEN
  Future<String?> getAccessToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('access');

  }
}
