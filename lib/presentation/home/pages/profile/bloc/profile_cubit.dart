import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:julink/data/models/profile/profile.dart';
import 'package:julink/data/repository/profile/profile_repository.dart';

/// ---- States ----
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

/// ---- Cubit ----
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(ProfileInitial()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await profileRepository.getProfileData();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> deleteProfileImage() async {
    emit(ProfileImageDeleting());
    try {
      await profileRepository.deleteProfileImage();
      final profile = await profileRepository.getProfileData();
      emit(ProfileImageDeleted());
      emit(ProfileLoaded(profile));
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
}
