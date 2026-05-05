import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Local CORS Proxy running on http://localhost:8080');

  await for (HttpRequest request in server) {
    // Add CORS headers to all responses
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    try {
      // The target URL is passed as a query parameter or just hardcoded for TollGuru
      final targetUrl = Uri.parse('https://apis.tollguru.com/toll/v2/origin-destination-waypoints');
      
      // Read body
      final bodyString = await utf8.decoder.bind(request).join();

      // Forward headers
      final headers = <String, String>{};
      request.headers.forEach((name, values) {
        if (name.toLowerCase() != 'host' && name.toLowerCase() != 'content-length') {
          headers[name] = values.join(',');
        }
      });

      // Send request to TollGuru
      final response = await http.post(
        targetUrl,
        headers: headers,
        body: bodyString,
      );

      // Return response
      request.response.statusCode = response.statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(response.body);
      await request.response.close();
      print('Proxy forwarded request. Status: ${response.statusCode}');
    } catch (e) {
      print('Proxy error: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Proxy error: $e');
      await request.response.close();
    }
  }
}
