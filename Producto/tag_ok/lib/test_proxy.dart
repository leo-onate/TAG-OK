import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://thingproxy.freeboard.io/fetch/https://apis.tollguru.com/toll/v2/origin-destination-waypoints');
  final body = jsonEncode({
    "from": {"lat": -33.4489, "lng": -70.6693},
    "to": {"lat": -33.0472, "lng": -71.6127},
    "vehicle": {"type": "2AxlesAuto"}
  });

  try {
    print('Sending request to TollGuru via thingproxy...');
    final response = await http.post(
      url,
      headers: {
        'x-api-key': 'tg_65A671FAC41C4A1782CFBE2678B16F2C',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
  } catch (e) {
    print('Exception: $e');
  }
}
