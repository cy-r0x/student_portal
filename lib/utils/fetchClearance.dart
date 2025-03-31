import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>?> getClearance(String accessToken) async {
  final url =
      Uri.parse('http://203.190.10.22:8006/accounts/semester-exam-clearance');

  try {
    final response = await http.get(
      url,
      headers: {
        'accesstoken': accessToken, // Use the access token directly
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data; // Return the parsed credit data
    } else {
      // Handle non-200 status codes
      print(
          'Error: Failed to fetch credit data. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // Handle network or parsing errors
    print('Error: $e');
    return null;
  }
}
