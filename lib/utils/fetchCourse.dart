import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>?> fetchCourse(
    String accessToken, String semID) async {
  final url = 'http://203.190.10.22:8189/registeredCourse?semesterId=$semID';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'accesstoken': accessToken},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
          .toList();
    }
    return null;
  } catch (e) {
    return null;
  }
}
