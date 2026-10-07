import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://nemesis-another-upon.ngrok-free.dev/api';
    } else {
      return 'https://nemesis-another-upon.ngrok-free.dev/api';
    }
  }

  static const Map<String, String> _headers = {
    'ngrok-skip-browser-warning': 'true',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> fetchArticles({int page = 1, String searchQuery = ''}) async {
    final queryParams = 'page=$page${searchQuery.isNotEmpty ? '&search=$searchQuery' : ''}';
    final response = await http.get(
      Uri.parse('$baseUrl/scp-articles?$queryParams'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('API Error (fetchArticles): ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load articles');
    }
  }

  static Future<Map<String, dynamic>> fetchArticleDetail(String link) async {
    final response = await http.get(
      Uri.parse('$baseUrl/scp-articles/$link'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('API Error (fetchArticleDetail): ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load article detail');
    }
  }
}
