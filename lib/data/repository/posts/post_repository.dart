// lib/data/repository/posts/post_repository.dart
import 'package:http/http.dart';
import 'package:julink/data/models/posts/post.dart';
import 'package:julink/data/sources/posts/post_service.dart';

class PostRepository {
  final PostService postService;
  PostRepository({required this.postService});

  // ---------- CREATE ----------
  Future<dynamic> createPost(String content, List<int> taggedCollegeIds) async {
    try {
      print("im in post repository createPost function");
      final response = await postService.createPost(content, taggedCollegeIds);
      // print(response.data);
      return Post.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // ---------- EDIT ----------
  Future<dynamic> editPost(
    int postId,
    String content,
    List<int> taggedCollegeIds,
  ) async {
    try {
      print("im in post repository editPost function");
      final response = await postService.editPost(
        postId,
        content,
        taggedCollegeIds,
      );
      // print(response.data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to edit post: $e');
    }
  }

  // ---------- UPLOAD IMAGE ----------
  Future<dynamic> uploadImage(int postId, dynamic fileImage) async {
    try {
      print("im in post repository uploadImage function");
      final response = await postService.uploadImage(postId, fileImage);
      // print(response.data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // ---------- DELETE ----------
  Future<dynamic> deletePost(int postId) async {
    try {
      print("im in post repository deletePost function");
      final response = await postService.deletePost(postId);
      // print(response.data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // ---------- FEED / HOMEPAGE ----------
  Future<dynamic> getHomePage({int page = 0, int size = 10}) async {
    try {
      print("im in post repository getHomePage function");
      final response = await postService.getHomePage(page: page, size: size);
      print(response.data);

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch homepage: $e');
    }
  }

  // ---------- LIKE ----------
  Future<dynamic> likePost(int postId) async {
    try {
      print("im in post repository likePost function");
      final response = await postService.likePost(postId);
      // print(response.data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // ---------- DELETE LIKE ----------
  Future<dynamic> deleteLike(int postId) async {
    try {
      print("im in post repository deleteLike function");
      final response = await postService.deleteLike(postId);
      // print(response.data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to remove like: $e');
    }
  }
}
