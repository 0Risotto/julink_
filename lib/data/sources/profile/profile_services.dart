import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  ProfileService({Dio? dio, this.baseUrl = "http://127.0.0.1:8080/api"})
    : _dio = dio ?? Dio();

  final String baseUrl; // should already include /api
  final Dio _dio;

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found or is empty');
    }
    return {'Authorization': 'Bearer $token'};
  }

  // ---------- GET /profile ----------
  Future<Response> getProfileData() async {
    final headers = await _authHeaders();
    return _dio.get(
      "$baseUrl/profile",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // ---------- PUT /profile ----------
  Future<Response> updateProfile(
    String firstName,
    String lastName,
    String major,
    int collegeId,
  ) async {
    final headers = await _authHeaders();
    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "major": major,
      "collegeId": collegeId,
    };

    return _dio.put(
      "$baseUrl/profile",
      data: body,
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // ---------- GET /profile/profile-image ----------
  // Returns null if 404 (no image set)
  Future<Uint8List?> getProfileImage() async {
    final headers = await _authHeaders();
    final res = await _dio.get<List<int>>(
      "$baseUrl/profile/profile-image", // no extra /api here
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    if (res.statusCode == 200 && res.data != null) {
      return Uint8List.fromList(res.data!);
    }
    if (res.statusCode == 404) return null; // no image
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Failed to fetch profile image (status ${res.statusCode})',
      type: DioExceptionType.badResponse,
    );
  }

  // ---------- DELETE /profile/profile-image ----------
  Future<Response> deleteProfileImage() async {
    final headers = await _authHeaders();
    return _dio.delete(
      "$baseUrl/profile/profile-image",
      options: Options(headers: headers),
    );
  }

  // ---------- PUT /profile/deactivate ----------
  Future<Response> deactivateAccount() async {
    final headers = await _authHeaders();
    return _dio.put(
      "$baseUrl/profile/deactivate",
      options: Options(headers: headers),
    );
  }
}
