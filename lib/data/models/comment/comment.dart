class Comment {
  final int id;
  final int postId;
  final int commenterId;
  final String commenterUsername;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.commenterId,
    required this.commenterUsername,
    required this.content,
    required this.createdAt,
    this.editedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
    id: j['id'],
    postId: j['postId'],
    commenterId: j['commenterId'],
    commenterUsername: j['commenterUsername'] ?? '',
    content: j['content'] ?? '',
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    editedAt: j['editedAt'] == null ? null : DateTime.tryParse(j['editedAt']),
  );

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'commenterId': commenterId,
    'commenterUsername': commenterUsername,
    'content': content,
  };
}
