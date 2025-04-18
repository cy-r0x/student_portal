import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getCreditData(String accessToken) async {
  final url =
      Uri.parse('http://203.190.10.22:8189/paymentLedger/paymentLedgerSummery');

  try {
    final response = await http.get(
      url,
      headers: {
        'accesstoken': accessToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
