import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  ProfileService({this.baseUrl = "http://127.0.0.1:8080/api"});
  final String baseUrl;
  late String? _token;

  // Retrieve token from SharedPreferences
  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token == null || _token!.isEmpty) {
      throw Exception('Token not found or is empty');
    }
  }

  // GET /profile
  Future<Response> getProfileData() async {
    await _getToken();
    final dio = Dio(
      BaseOptions(
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      ),
    );
    final response = await dio.get("$baseUrl/profile");
    return response;
  }

  // PUT /profile
  Future<Response> updateProfile(Map<String, dynamic> updatedProfile) async {
    await _getToken();
    final dio = Dio(
      BaseOptions(
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      ),
    );
    final response = await dio.put("$baseUrl/profile", data: updatedProfile);
    return response;
  }

  // GET /profile/profile-image
  Future<Uint8List> getProfileImage() async {
    await _getToken();
    final dio = Dio(
      BaseOptions(
        responseType: ResponseType.bytes,
        headers: {'Authorization': 'Bearer $_token'},
      ),
    );
    final response = await dio.get("$baseUrl/profile/profile-image");
    return Uint8List.fromList(response.data);
  }

  // DELETE /profile/profile-image
  Future<Response> deleteProfileImage() async {
    await _getToken();
    final dio = Dio(BaseOptions(headers: {'Authorization': 'Bearer $_token'}));
    final response = await dio.delete("$baseUrl/profile/profile-image");
    return response;
  }

  // PUT /profile/deactivate
  Future<Response> deactivateAccount() async {
    await _getToken();
    final dio = Dio(BaseOptions(headers: {'Authorization': 'Bearer $_token'}));
    final response = await dio.put("$baseUrl/profile/deactivate");
    return response;
  }
}
