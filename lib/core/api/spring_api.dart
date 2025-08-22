class SpringApi {
  static const String portPath = "http://localhost:8080";

  // entry related
  static const String entry = "${portPath}/entry";

  // login related
  static const String createUser = "${entry}/createUser";
  static const String loginUser = "${entry}/loginUser";
  static const String sendOTP = "${entry}/sendOTP";
  static const String checkOTP = "${entry}/checkOTPValidity";
  static const String resetPassword = "${entry}/resetPassword";
  static const String changePassword = "${entry}/changePassword";

  // posts related entry
  static const String uploadImage = "${entry}/upload-image";

  static const String bulk = "${portPath}/api";

  // Profile related (Bulk)
  static const String getProfile = "${bulk}/profile";
  static const String updateProfile = "${bulk}/profile";

  // Posts related functions (Bulk)
  static const String createPost = "${bulk}/posts";
  static const String getPosts = "${bulk}/posts";
  static const String editPost = "${bulk}/posts/{postId}";
  static const String deletePost = "${bulk}/posts/{postId}";

  // Comments related functions (Bulk)
  static const String createComment = "${bulk}/posts/{postId}/comments";
  static const String getCommentsByPost = "${bulk}/posts/{postId}/comments";
  static const String editComment = "${bulk}/comments/{commentId}";

  // Like related functions (Bulk)
  static const String addLike = "${bulk}/posts/{postId}/like";
  static const String removeLike = "${bulk}/posts/{postId}/like";
}
