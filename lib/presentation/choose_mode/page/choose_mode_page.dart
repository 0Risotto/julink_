import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/common/widgets/buttons/basic_app_button.dart';
import 'package:julink/core/configs/assets/app_vectors.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:julink/presentation/auth/signin_page.dart';
import 'package:julink/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatefulWidget {
  const ChooseModePage({super.key});

  @override
  State<ChooseModePage> createState() => _ChooseModePageState();
}

class _ChooseModePageState extends State<ChooseModePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          ),
          Container(color: Colors.black.withOpacity(0.15)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset(
                      AppVectors.logo,
                      height: 400,
                      width: 400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Choose Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode
                          ? AppColors.lightBackground
                          : AppColors.darkBackground,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dark Mode Button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<ThemeCubit>().updateTheme(
                                ThemeMode.dark,
                              );
                              setState(() {});
                            },
                            child: ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCancelButton
                                        .withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    AppVectors.moon,
                                    fit: BoxFit.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: context.isDarkMode
                                  ? AppColors.lightBackground
                                  : AppColors.darkBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      // Light Mode Button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<ThemeCubit>().updateTheme(
                                ThemeMode.light,
                              );
                              setState(() {});
                            },
                            child: ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCancelButton
                                        .withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    AppVectors.sun,
                                    fit: BoxFit.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Light Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: context.isDarkMode
                                  ? AppColors.lightBackground
                                  : AppColors.darkBackground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  BasicAppButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => SigninPage(),
                        ),
                      );
                    },
                    title: 'Continue',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
