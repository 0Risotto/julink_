// lib/presentation/spa/profile/bloc/profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:julink/data/models/profile/profile.dart';
import 'package:julink/data/repository/profile/profile_repository.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profileData;
  ProfileLoaded(this.profileData);
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError(this.error);
}

class ProfileDeactivating extends ProfileState {}

class ProfileDeactivated extends ProfileState {}

class ProfileImageDeleting extends ProfileState {}

class ProfileImageDeleted extends ProfileState {}

// ✅ Update states without data
class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;
  ProfileCubit({required this.profileRepository}) : super(ProfileInitial()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final p = await profileRepository.getProfileData();
      emit(ProfileLoaded(p));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> deleteProfileImage() async {
    emit(ProfileImageDeleting());
    try {
      await profileRepository.deleteProfileImage();
      emit(ProfileImageDeleted());
      await fetchProfile(); // refresh UI
    } catch (e) {
      emit(ProfileError('Failed to delete profile image: $e'));
    }
  }

  Future<void> deactivateAccount() async {
    emit(ProfileDeactivating());
    try {
      await profileRepository.deactivateAccount();
      emit(ProfileDeactivated());
    } catch (e) {
      emit(ProfileError('Failed to deactivate account: $e'));
    }
  }

  // ✅ Update method: no return; emit success and refresh
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String major,
    required int collegeId,
  }) async {
    emit(ProfileUpdating());
    try {
      await profileRepository.updateAccount(
        firstName,
        lastName,
        major,
        collegeId,
      );
      emit(ProfileUpdated());
      await fetchProfile(); // optional; remove if you don't want auto-refresh
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }
}
