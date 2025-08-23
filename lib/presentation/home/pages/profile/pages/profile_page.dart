// lib/presentation/auth/pages/profile_page.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/common/widgets/buttons/basic_app_button.dart';
import 'package:julink/common/widgets/buttons/common_app_button.dart';
import 'package:julink/common/widgets/buttons/danger_buttons.dart';
import 'package:julink/core/configs/assets/app_vectors.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:julink/data/models/profile/profile.dart';
import 'package:julink/data/sources/profile/profile_services.dart';
import 'package:julink/data/repository/profile/profile_repository.dart';
import 'package:julink/presentation/home/pages/profile/bloc/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileService = ProfileService();
    return BlocProvider(
      create: (context) => ProfileCubit(
        profileRepository: ProfileRepository(
          profileService: profileService,
        ), // <— correct name
      ),
      child: Scaffold(
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              Profile profile = state.profileData;
              return ProfilePageContainer(profile: profile);
            } else if (state is ProfileError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return Center(child: Text("NO STATES"));
          },
        ),
      ),
    );
  }
}

class ProfilePageContainer extends StatefulWidget {
  final Profile profile;

  ProfilePageContainer({required this.profile});

  @override
  _ProfilePageContainerState createState() => _ProfilePageContainerState();
}

class _ProfilePageContainerState extends State<ProfilePageContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 2 tabs: own posts and liked posts
  }

  @override
  void dispose() {
    _tabController.dispose(); // Clean up the controller when not in use
    super.dispose();
  }

  Widget commonRichText(int number, String title, BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$number ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: context.isDarkMode ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  // Function to show the Edit Profile dialog
  void _showEditProfileDialog(Profile profile) {
    TextEditingController _usernameController = TextEditingController(
      text: profile.username,
    );
    TextEditingController _firstNameController = TextEditingController(
      text: profile.firstName,
    );
    TextEditingController _lastNameController = TextEditingController(
      text: profile.lastName,
    );

    // Placeholder for the profile picture URL or an image picker logic
    String? _profilePicture = "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: context.isDarkMode
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile picture section (replace with actual image picker logic)
                _profilePicture != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_profilePicture),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.camera_alt),
                      ),
                SizedBox(height: 16),
                // Input fields for username, first name, and last name
                _buildTextField(_usernameController, "Username", context),
                SizedBox(height: 12),
                _buildTextField(_firstNameController, "First Name", context),
                SizedBox(height: 12),
                _buildTextField(_lastNameController, "Last Name", context),
                SizedBox(height: 20),

                // Save button
                Row(
                  children: [
                    Expanded(
                      child: BasicAppButton(
                        onPressed: () async {
                          // Save logic goes here
                          // You can use the controllers to fetch the updated values
                          String majorName = _usernameController.text.trim();
                          String firstName = _firstNameController.text.trim();
                          String lastName = _lastNameController.text.trim();
                          var collegeid = 1;
                          await context.read<ProfileCubit>().updateProfile(
                            firstName: firstName,
                            lastName: lastName,
                            major: majorName,
                            collegeId: collegeid,
                          );
                          // Close the dialog after saving
                          Navigator.of(context).pop();
                        },
                        title: "Save Changes",
                      ),
                    ),
                    Expanded(
                      child: DangerButton(
                        onPressed: () async {
                          await context
                              .read<ProfileCubit>()
                              .deleteProfileImage();
                          Navigator.of(context).pop();
                        },
                        title: "Delete PFP",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
        border: OutlineInputBorder(),
      ),
    );
  }

  bool _ispfpEmpty() {
    return widget.profile.profileImage != "";
  }

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = Base64Decoder().convert(widget.profile.profileImage);
    //Uint8List imageBytes = widget.profile.profileImage;

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: _ispfpEmpty()
                    ? Image.memory(
                        imageBytes,
                        height: 150,
                        width: 150,
                        fit: BoxFit
                            .cover, // Ensures the image fills the circle while maintaining aspect ratio
                      )
                    : SvgPicture.asset(
                        AppVectors.defaultProfilePicture,
                        height: 150,
                        width: 150,
                      ),
              ),
              SizedBox(width: 20), // Space between profile picture and text
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns text to the left
                  children: [
                    Row(
                      children: [
                        Text(
                          "@" + widget.profile.username,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CommonButton(
                          onPressed: () {
                            _showEditProfileDialog(
                              widget.profile,
                            ); // Trigger Edit Profile Dialog
                          },
                          title: "Edit Profile",
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        commonRichText(
                          widget.profile.posts.length,
                          "posts",
                          context,
                        ),
                        SizedBox(width: 4),
                        commonRichText(0, "followings", context),
                        SizedBox(width: 4),
                        commonRichText(0, "followers", context),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.school_rounded, size: 16),
                        Text(
                          "University of Jordan",
                          style: TextStyle(
                            color: context.isDarkMode
                                ? Colors.white54
                                : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_city_rounded, size: 16),
                        Text(
                          "${widget.profile.firstName} ${widget.profile.lastName}",
                          style: TextStyle(
                            color: context.isDarkMode
                                ? Colors.white54
                                : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // TabBar and TabBarView for navigation
          SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Own Posts"),
              Tab(text: "Liked Posts"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(child: Text("Own posts")),
                Container(child: Text("Liked posts")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
