import 'package:http/http.dart' as http;
import 'dart:convert';

/// Function to handle login API requests
///
/// Returns a Map containing the API response or null if the request fails
Future<Map<String, dynamic>?> fetchLogin(
    String username, String password) async {
  final url = Uri.parse('http://203.190.10.22:8189/login');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
        'grecaptcha': '',
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Parse the response body
    } else {
      // Handle API error
      return {'error': 'Login failed with status code ${response.statusCode}'};
    }
  } catch (e) {
    // Handle network or parsing errors
    print('Error: $e');
    return {'error': 'Network or server error occurred'};
  }
}
