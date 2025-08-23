import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final String baseUrl; // should already include /api

  PostService({Dio? dio, this.baseUrl = "http://127.0.0.1:8080/api"})
    : _dio = dio ?? Dio();
  final Dio _dio;

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found or is empty');
    }
    return {'Authorization': 'Bearer $token'};
  }

  // feed post functions
  //post
  Future<dynamic> createPost(String content, List<int> taggedCollegeIds) async {
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

  //put
  Future<dynamic> editPost(
    int postId,
    String content,
    List<int> taggedCollegeIds,
  ) async {
    final headers = await _authHeaders();
    final body = {"content": content, "taggedCollegeIds": taggedCollegeIds};
    return _dio.put(
      "$baseUrl/homepage/$postId",
      data: body,
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // post
  Future<dynamic> uploadImage(int postId, FileImage file) async {
    //not done yet
    final headers = await _authHeaders();
    return _dio.post(
      "$baseUrl/posts/$postId/image",
      data: {"file": "$file"},
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  Future<dynamic> deletePost(int postId) async {
    final headers = await _authHeaders();
    print("post id to delete ${postId}");
    return _dio.delete(
      "$baseUrl/posts/$postId",
      data: {"postId": postId},

      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  //------------end of feed posts functions------------------
  Future<dynamic> getHomePage({int page = 0, int size = 10}) async {
    final headers = await _authHeaders();
    print("im in gethomepage service");
    return _dio.get(
      "$baseUrl/posts/homepage",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // -- start of like funcitons

  Future<dynamic> likePost(int postId) async {
    //not done yet
    final headers = await _authHeaders();
    return _dio.post(
      "$baseUrl/posts/$postId/like",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  Future<dynamic> deleteLike(int postId) async {
    final headers = await _authHeaders();
    return _dio.delete(
      "$baseUrl/posts/$postId/like",
      options: Options(
        headers: {...headers, 'Content-Type': 'application/json'},
      ),
    );
  }

  // -- end of like funcitons
}
  

  // comment functions 

  //get funcitons
 

