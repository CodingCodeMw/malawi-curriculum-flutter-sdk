import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/models.dart';

class MalawiCurriculumClient {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  MalawiCurriculumClient({
    required this.apiKey,
    this.baseUrl = 'https://malawi-curricular-api-production.up.railway.app/api/v1',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<T> _get<T>(String endpoint, Map<String, dynamic> query, T Function(dynamic) parser) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: 
      query.map((key, value) => MapEntry(key, value?.toString()))
        ..removeWhere((key, value) => value == null)
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return parser(json);
  }

  /// Get filtered resources
  Future<List<Resource>> getResources({
    String? level,
    String? subject,
    String? type,
    int? year,
    int? limit,
    int? offset,
  }) async {
    return _get('/resources', {
      'level': level,
      'subject': subject,
      'type': type,
      'year': year,
      'limit': limit,
      'offset': offset,
    }, (json) {
      final List data = json['data'];
      return data.map((e) => Resource.fromJson(e)).toList();
    });
  }

  /// Get all subjects, optionally filtered by level
  Future<List<Subject>> getSubjects({String? level}) async {
    return _get('/subjects', {
      'level': level,
    }, (json) {
      final List data = json['data'];
      return data.map((e) => Subject.fromJson(e)).toList();
    });
  }

  /// Get all education levels
  Future<List<String>> getLevels() async {
    return _get('/levels', {}, (json) {
      final List data = json['data'];
      // Assuming level API returns objects with 'name' property based on JS SDK analysis
      // But let's check levels.js again.
      // levels.js says: `SELECT id, name FROM levels`. Response: `data: [{id: 1, name: 'MSCE'}]`
      return data.map((e) => e['name'] as String).toList();
    });
  }

  /// Get download URL for a resource (Paid plans only)
  Future<String> downloadResource(int id) async {
    return _get('/resources/$id/download', {}, (json) {
      return json['download_url'] as String;
    });
  }
}
