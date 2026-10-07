import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../api_service.dart';
import '../../domain/entities/scp_detail.dart';

abstract class ScpRemoteDataSource {
  Future<Map<String, dynamic>> fetchArticles({int page = 1, String searchQuery = ''});
  Future<ScpDetail> fetchArticleDetail(String link);
}

@LazySingleton(as: ScpRemoteDataSource)
class ScpRemoteDataSourceImpl implements ScpRemoteDataSource {
  static String get baseUrl => ApiService.baseUrl;
  final http.Client client;

  static const Map<String, String> _headers = {
    'ngrok-skip-browser-warning': 'true',
    'Accept': 'application/json',
  };

  ScpRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> fetchArticles({int page = 1, String searchQuery = ''}) async {
    final queryParams = 'page=$page${searchQuery.isNotEmpty ? '&search=$searchQuery' : ''}';
    final uri = Uri.parse('$baseUrl/scp-articles?$queryParams');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data SCP (Status: ${response.statusCode})');
    }
  }

  @override
  Future<ScpDetail> fetchArticleDetail(String link) async {
    final uri = Uri.parse('$baseUrl/scp-articles/${Uri.encodeComponent(link)}');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ScpDetail(
        scp: data['scp']?.toString() ?? 'N/A',
        title: data['title']?.toString() ?? 'Untitled SCP',
        rating: (data['rating'] is int)
            ? data['rating']
            : int.tryParse(data['rating']?.toString() ?? '0') ?? 0,
        series: data['series']?.toString(),
        rawContent: data['raw_content']?.toString() ?? '<p>Konten tidak ditemukan.</p>',
        requiredClearance: data['required_clearance'] is int
            ? data['required_clearance']
            : int.tryParse(data['required_clearance']?.toString() ?? '1') ?? 1,
      );
    } else {
      throw Exception('Gagal mengambil detail SCP (Status: ${response.statusCode})');
    }
  }
}
