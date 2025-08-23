// lib/data/repositories/profile_repository.dart

import 'package:julink/data/models/posts/post.dart';
import 'package:julink/data/models/profile/profile.dart';
import 'package:julink/data/sources/profile/profile_services.dart';

class ProfileRepository {
  final ProfileService profileService;
  ProfileRepository({required this.profileService});
  // Fetch profile data
  Future<dynamic> getProfileData() async {
    try {
      print(" im in profile repositry getprofile function");
      final response = await profileService.getProfileData();
      //print(response.data);
      return Profile.fromJson(response.data);
      // return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<dynamic> deleteProfileImage() async {
    try {
      print(" im in profile repositry getprofile function");
      final response = await profileService.deleteProfileImage();
      print(response.data);
      // return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<dynamic> deactivateAccount() async {
    try {
      print(" im in profile repositry getprofile function");
      final response = await profileService.deactivateAccount();
      print(response.data);
      // return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<dynamic> updateAccount(
    String firstName,
    String lastName,
    String major,
    int collegeId,
  ) async {
    try {
      final response = await profileService.updateProfile(
        firstName,
        lastName,
        major,
        collegeId,
      );
      print(response.data);
    } catch (e) {
      throw Exception('Failed to update $e');
    }
  }
}
