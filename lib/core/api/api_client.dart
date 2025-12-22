import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Map<String, String> _defaultHeaders;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    Map<String, String>? defaultHeaders,
  })  : _httpClient = httpClient ?? http.Client(),
        _defaultHeaders = {
          'accept': 'application/json',
          ...?defaultHeaders,
        };

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _httpClient.get(
      uri,
      headers: {..._defaultHeaders, ...?headers},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, response.body);
  }

  void dispose() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}
