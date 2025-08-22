// data/models/profile.dart
class Profile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String major;
  final int collegeId;
  final String collegeName;
  final String role;
  final String profileImage; // Assuming it is a URL or base64 string
  final List<int> followingIds; // List of user IDs this profile is following
  final List<int> followerIds; // List of user IDs following this profile
  final List<dynamic> posts; // Replace with Post model when ready
  final List<dynamic> comments; // Replace with Comment model when ready

  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.major,
    required this.collegeId,
    required this.collegeName,
    required this.role,
    required this.profileImage,
    required this.followingIds,
    required this.followerIds,
    required this.posts,
    required this.comments,
  });

  // Factory constructor to create a Profile from a JSON map
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      major: json['major'] ?? '',
      collegeId: json['collegeId'] ?? 0,
      collegeName: json['collegeName'] ?? '',
      role: json['role'] ?? '',
      profileImage: json['profileImage'] ?? '',
      followingIds: List<int>.from(json['followingIds'] ?? []),
      followerIds: List<int>.from(json['followerIds'] ?? []),
      posts: json['posts'] ?? [],
      comments: json['comments'] ?? [],
    );
  }

  // Convert the Profile object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'major': major,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'role': role,
      'profileImage': profileImage,
      'followingIds': followingIds,
      'followerIds': followerIds,
      'posts': posts,
      'comments': comments,
    };
  }
}
