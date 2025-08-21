import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  final http.Client _client;
  HttpClient([http.Client? client]) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final res = await _client.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw HttpException('GET ${uri.toString()} -> ${res.statusCode}');
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
