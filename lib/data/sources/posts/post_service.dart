// lib/data/sources/posts/post_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final String baseUrl; // should already include /api
  final Dio _dio;

  PostService({Dio? dio, this.baseUrl = "http://127.0.0.1:8080/api"})
    : _dio = dio ?? Dio();

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found or is empty');
    }
    return {'Authorization': 'Bearer $token'};
  }

  // -------- feed post functions --------

  // POST /posts
  Future<Response> createPost(
    String content,
    List<int> taggedCollegeIds,
  ) async {
    final headers = await _authHeaders();
    final body = {"content": content, "taggedCollegeIds": taggedCollegeIds};
    return _dio.post(
      "$baseUrl/posts",
      data: body,
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // PUT (verify your endpoint path — many backends use /posts/:id)
  Future<Response> editPost(
    int postId,
    String content,
    List<int> taggedCollegeIds,
  ) async {
    final headers = await _authHeaders();
    final body = {"content": content, "taggedCollegeIds": taggedCollegeIds};
    return _dio.put(
      "$baseUrl/homepage/$postId", // TODO: confirm this path; often it's "$baseUrl/posts/$postId"
      data: body,
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // POST /posts/:id/image (multipart)
  Future<Response> uploadImage(int postId, MultipartFile file) async {
    final headers = await _authHeaders();

    final form = FormData.fromMap({
      // Change 'file' if your backend expects a different field name
      'file': file,
    });

    return _dio.post(
      "$baseUrl/posts/$postId/image",
      data: form,
      options: Options(headers: headers, contentType: 'multipart/form-data'),
    );
  }

  // DELETE /posts/:id
  Future<Response> deletePost(int postId) async {
    final headers = await _authHeaders();
    return _dio.delete(
      "$baseUrl/posts/$postId",
      data: {"postId": postId},
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // GET /posts/homepage
  Future<Response> getHomePage({int page = 0, int size = 10}) async {
    final headers = await _authHeaders();
    return _dio.get(
      "$baseUrl/posts/homepage",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // POST /posts/:id/like
  Future<Response> likePost(int postId) async {
    final headers = await _authHeaders();
    return _dio.post(
      "$baseUrl/posts/$postId/like",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // DELETE /posts/:id/like
  Future<Response> deleteLike(int postId) async {
    final headers = await _authHeaders();
    return _dio.delete(
      "$baseUrl/posts/$postId/like",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }
}
