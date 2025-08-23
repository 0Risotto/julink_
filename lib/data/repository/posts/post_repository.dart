// lib/data/repository/posts/post_repository.dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:julink/data/models/posts/post.dart';
import 'package:julink/data/sources/posts/post_service.dart';

class PostRepository {
  final PostService postService;
  PostRepository({required this.postService});

  // ---------- CREATE ----------
  Future<dynamic> createPost(String content, List<int> taggedCollegeIds) async {
    try {
      final response = await postService.createPost(content, taggedCollegeIds);
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
      final response = await postService.editPost(
        postId,
        content,
        taggedCollegeIds,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to edit post: $e');
    }
  }

  // ---------- UPLOAD IMAGE ----------
  // Accepts either an XFile (from image_picker) or a ready MultipartFile.
  Future<dynamic> uploadImage(int postId, dynamic fileImage) async {
    try {
      late final MultipartFile file;

      if (fileImage is XFile) {
        // Web-safe: use bytes; also works on mobile
        final bytes = await fileImage.readAsBytes();
        file = MultipartFile.fromBytes(
          bytes,
          filename: fileImage.name,
          contentType: MediaType('image', _inferImageExt(fileImage.name)),
        );
      } else if (fileImage is MultipartFile) {
        file = fileImage;
      } else {
        throw ArgumentError('fileImage must be an XFile or MultipartFile');
      }

      final response = await postService.uploadImage(postId, file);
      return response.data;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  String _inferImageExt(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'png';
    if (n.endsWith('.webp')) return 'webp';
    if (n.endsWith('.heic') || n.endsWith('.heif')) return 'heic';
    return 'jpeg'; // default
  }

  // ---------- DELETE ----------
  Future<dynamic> deletePost(int postId) async {
    try {
      final response = await postService.deletePost(postId);
      return response.data;
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // ---------- FEED / HOMEPAGE ----------
  Future<dynamic> getHomePage({int page = 0, int size = 10}) async {
    try {
      final response = await postService.getHomePage(page: page, size: size);
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch homepage: $e');
    }
  }

  // ---------- LIKE ----------
  Future<dynamic> likePost(int postId) async {
    try {
      final response = await postService.likePost(postId);
      return response.data;
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // ---------- DELETE LIKE ----------
  Future<dynamic> deleteLike(int postId) async {
    try {
      final response = await postService.deleteLike(postId);
      return response.data;
    } catch (e) {
      throw Exception('Failed to remove like: $e');
    }
  }
}
