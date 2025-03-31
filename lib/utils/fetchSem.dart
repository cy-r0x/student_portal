import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>?> fetchSem(String accessToken) async {
  const url = 'http://203.190.10.22:8006/registeredCourse/semesterList';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'accesstoken': accessToken},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<Map<String, dynamic>>((item) => {
                'semesterId': item['semesterId'].toString(),
                'semesterYear': int.parse(item['semesterYear'].toString()),
                "semesterName": item["semesterName"].toString(),
              })
          .toList();
    }
    return null;
  } catch (e) {
    return null;
  }
}
