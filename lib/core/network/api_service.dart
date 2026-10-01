import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  final String baseUrl;
  String? _accessToken;

  ApiService({
    http.Client? client,
    this.baseUrl = "https://pos.cicd.web.id",
  }) : client = client ?? http.Client();

  Future<void> _ensureAuthenticated() async {
    if (_accessToken != null) return;
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': 'praktikum@gmail.com', 'password': '12345678'}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['data']['access_token'];
    } else {
      throw Exception('Gagal Autentikasi API: ${response.body}');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    await _ensureAuthenticated();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('GET Error (${response.statusCode}): ${response.body}');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await client.post(Uri.parse('$baseUrl/$endpoint'), headers: headers, body: json.encode(data));
    if (response.statusCode == 200 || response.statusCode == 201) return json.decode(response.body);
    throw Exception('POST Error (${response.statusCode}): ${response.body}');
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await client.patch(Uri.parse('$baseUrl/$endpoint'), headers: headers, body: json.encode(data));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('PATCH Error (${response.statusCode}): ${response.body}');
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.delete(Uri.parse('$baseUrl/$endpoint'), headers: headers);
    if (response.statusCode == 200 || response.statusCode == 204) return true;
    throw Exception('DELETE Error (${response.statusCode}): ${response.body}');
  }

  // --- FITUR UPLOAD GAMBAR ---
  Future<String> uploadFile(File file) async {
    await _ensureAuthenticated();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files'));
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data']['id']; // Mengembalikan UUID Gambar
    } else {
      throw Exception('Gagal upload gambar: ${response.body}');
    }
  }
}