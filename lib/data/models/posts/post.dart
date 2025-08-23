// lib/data/models/posts/post.dart
import 'dart:convert';
import 'dart:typed_data';

class Post {
  final int id;
  final int authorId;
  final String authorUsername;
  final String content;
  final String? postTitle;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<int> taggedCollegeIds;
  final int likeCount;

  /// Backend sends base64 string or null. Keep it nullable.
  final String? image;

  final int? commentsCount;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.content,
    this.postTitle,
    required this.createdAt,
    this.editedAt,
    this.taggedCollegeIds = const [],
    this.likeCount = 0,
    this.image,
    this.commentsCount,
  });

  // ---------- helpers ----------
  static int _toInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse('$v') ?? def;
  }

  static String _toStr(dynamic v, [String def = '']) {
    if (v == null) return def;
    return '$v';
  }

  static String? _toStrOrNull(dynamic v) {
    if (v == null) return null;
    final s = '$v';
    return s.isEmpty ? null : s;
  }

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) {
      // epoch seconds vs. millis heuristic
      final isMillis = v > 2000000000;
      return DateTime.fromMillisecondsSinceEpoch(isMillis ? v : v * 1000);
    }
    final s = '$v';
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  /// Decode [image] to bytes for Image.memory. Null-safe.
  Uint8List? get imageBytes {
    final s = image;
    if (s == null || s.isEmpty) return null;
    // Supports "data:image/png;base64,...."
    final parts = s.split(',');
    final b64 = parts.length > 1 ? parts.last : s;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  bool get hasImage => imageBytes != null;

  // ---------- JSON ----------
  factory Post.fromJson(Map<String, dynamic> j) {
    // Normalize possible shapes of `image`
    String? img;
    final iv = j['image'];
    if (iv == null) {
      img = null;
    } else if (iv is String) {
      img = iv; // base64 already
    } else if (iv is List) {
      // If server sends List<int>, convert to base64 for consistent storage
      final ints = iv.whereType<int>().toList();
      img = ints.isEmpty ? null : base64Encode(ints);
    } else {
      img = _toStrOrNull(iv);
    }

    return Post(
      id: _toInt(j['id']),
      authorId: _toInt(j['authorId']),
      authorUsername: _toStr(j['authorUsername']),
      content: _toStr(j['content']),
      postTitle: _toStrOrNull(j['postTitle']),
      createdAt: _toDate(j['createdAt']),
      editedAt: j['editedAt'] == null ? null : _toDate(j['editedAt']),
      taggedCollegeIds: (j['taggedCollegeIds'] as List? ?? const [])
          .map((e) => _toInt(e))
          .toList(),
      likeCount: _toInt(j['likeCount']),
      image: img, // normalized
      commentsCount: j['commentsCount'] == null
          ? null
          : _toInt(j['commentsCount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'authorUsername': authorUsername,
    'content': content,
    'postTitle': postTitle,
    'createdAt': createdAt.toIso8601String(),
    'editedAt': editedAt?.toIso8601String(),
    'taggedCollegeIds': taggedCollegeIds,
    'likeCount': likeCount,
    'image': image, // still base64 or null
    'commentsCount': commentsCount,
  };
}
