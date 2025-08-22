class Post {
  final int authorId;
  final String content;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final List<int> taggedCollegeIds;
  final String authorUsername;
  final int likeCount;
  final String? image; // base64 or URL
  final String postTitle;

  Post({
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.editedAt,
    required this.taggedCollegeIds,
    required this.authorUsername,
    required this.likeCount,
    required this.image,
    required this.postTitle,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      authorId: (json['authorId'] ?? 0) is int
          ? json['authorId']
          : int.tryParse(json['authorId'].toString()) ?? 0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      taggedCollegeIds: (json['taggedCollegeIds'] as List<dynamic>? ?? [])
          .map((e) => (e is int) ? e : int.tryParse(e.toString()) ?? 0)
          .toList(),
      authorUsername: json['authorUsername'] ?? '',
      likeCount: (json['likeCount'] ?? 0) is int
          ? json['likeCount']
          : int.tryParse(json['likeCount'].toString()) ?? 0,
      image: json['image'], // nullable
      postTitle: json['postTitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'taggedCollegeIds': taggedCollegeIds,
      'authorUsername': authorUsername,
      'likeCount': likeCount,
      'image': image,
      'postTitle': postTitle,
    };
  }
}
