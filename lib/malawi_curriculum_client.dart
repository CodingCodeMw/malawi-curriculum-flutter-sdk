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

  /// Helper for authenticated POST requests
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
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
      return data.map((e) => e['name'] as String).toList();
    });
  }

  /// Search resources with plan-tiered filtering
  ///
  /// [q] Search query (required, min 2 characters)
  /// [level] Filter by level (Basic+ plans)
  /// [subject] Filter by subject (Basic+ plans)
  /// [type] Filter by resource type (Pro+ plans)
  /// [year] Filter by year (Pro+ plans)
  /// [limit] Max results (capped by plan tier)
  /// [offset] Pagination offset
  /// [sort] Sort order - Enterprise only ('relevance', 'newest', 'oldest', 'title')
  Future<Map<String, dynamic>> search({
    required String q,
    String? level,
    String? subject,
    String? type,
    int? year,
    int? limit,
    int? offset,
    String? sort,
  }) async {
    return _get('/search', {
      'q': q,
      'level': level,
      'subject': subject,
      'type': type,
      'year': year,
      'limit': limit,
      'offset': offset,
      'sort': sort,
    }, (json) => json as Map<String, dynamic>);
  }

  /// Request a secure download token (paid plans only)
  ///
  /// Returns a map with 'token', 'expires_in_seconds', and 'download_url'
  Future<Map<String, dynamic>> requestDownload(int resourceId) async {
    return _post('/downloads/request', {'resourceId': resourceId});
  }

  /// Redeem a download token to get the signed file URL
  ///
  /// Returns a map with 'download_url', 'expires_in_seconds', and 'attempts_remaining'
  Future<Map<String, dynamic>> redeemDownload(String token) async {
    return _get('/downloads/$token', {}, (json) => json as Map<String, dynamic>);
  }

  /// Convenience: Request token and redeem in one call
  ///
  /// Returns the signed download URL string
  Future<String> download(int resourceId) async {
    final tokenData = await requestDownload(resourceId);
    final downloadData = await redeemDownload(tokenData['token'] as String);
    return downloadData['download_url'] as String;
  }

  /// @deprecated Use [requestDownload] + [redeemDownload] or [download] instead
  @Deprecated('Use download() for the secure token flow')
  Future<String> downloadResource(int id) async {
    return _get('/resources/$id/download', {}, (json) {
      return json['download_url'] as String;
    });
  }
}
