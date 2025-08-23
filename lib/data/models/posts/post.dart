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
  final Uint8List? image; // decoded from base64 or list<int>
  final int? commentsCount; // optional

  Post({
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

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) {
      // treat as epoch millis/seconds (heuristic)
      final isMillis = v > 2000000000; // >~ 2033 in seconds
      return DateTime.fromMillisecondsSinceEpoch(isMillis ? v : v * 1000);
    }
    final s = '$v';
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  static Uint8List? _toBytes(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      if (v.isEmpty) return null;
      // Some backends send "data:image/jpeg;base64,...."
      final parts = v.split(',');
      final b64 = parts.length > 1 ? parts.last : v;
      try {
        return base64Decode(b64);
      } catch (_) {
        return null;
      }
    }
    if (v is List) {
      // list<int> → Uint8List
      final ints = v.whereType<int>().toList();
      return Uint8List.fromList(ints);
    }
    return null;
  }

  // ---------- JSON ----------
  factory Post.fromJson(Map<String, dynamic> j) {
    return Post(
      id: _toInt(j['id']),
      authorId: _toInt(j['authorId']),
      authorUsername: _toStr(j['authorUsername']),
      content: _toStr(j['content']),
      postTitle: (j['postTitle'] == null || '${j['postTitle']}'.isEmpty)
          ? null
          : _toStr(j['postTitle']),
      createdAt: _toDate(j['createdAt']),
      editedAt: j['editedAt'] == null ? null : _toDate(j['editedAt']),
      taggedCollegeIds: (j['taggedCollegeIds'] as List? ?? const [])
          .map((e) => _toInt(e))
          .toList(),
      likeCount: _toInt(j['likeCount']),
      image: _toBytes(j['image']),
      commentsCount: j['commentsCount'] == null
          ? null
          : _toInt(j['commentsCount']),
    );
  }

  Map<String, dynamic> toJson() => {
    // NOTE:  backend sets author via @AuthenticationPrincipal,
    // but we keep fields for symmetry.
    'authorId': authorId,
    'authorUsername': authorUsername,
    'content': content,
    'postTitle': postTitle,
    'createdAt': createdAt.toIso8601String(),
    'editedAt': editedAt?.toIso8601String(),
    'taggedCollegeIds': taggedCollegeIds,
    'likeCount': likeCount,
    // For JSON body, backend expects byte[]; base64 is typical wire format
    'image': image == null ? null : base64Encode(image!),
  };
}
