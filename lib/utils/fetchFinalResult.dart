import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>?> fetchFinalResult(
    String semesterId, String studentId) async {
  try {
    final response = await http.get(
      Uri.parse(
          'http://203.190.10.22:8189/result?grecaptcha=&semesterId=$semesterId&studentId=$studentId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data.isNotEmpty) {
        return data;
      }
    }
    return null;
  } catch (e) {
    print('Error fetching result: $e');
    return null;
  }
}
