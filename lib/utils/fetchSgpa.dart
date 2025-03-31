// fetchSgpa.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>?> fetchSGPA(String accessToken) async {
  const url = 'http://203.190.10.22:8006/dashboard/studentSGPAGraph';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'accesstoken': accessToken},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<Map<String, dynamic>>((item) => {
                'semester': item['semester'].toString(),
                'sgpa': double.parse(item['sgpa'].toString())
              })
          .toList();
    }
    return null;
  } catch (e) {
    return null;
  }
}
