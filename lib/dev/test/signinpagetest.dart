import 'dart:convert';
import 'package:julink/presentation/auth/signup_page.dart';
import 'package:julink/presentation/home/pages/feed/page/feed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/common/widgets/buttons/basic_app_button.dart';
import 'package:julink/core/api/spring_api.dart';
import 'package:julink/core/configs/assets/app_vectors.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class testingSigninPage extends StatefulWidget {
  const testingSigninPage({super.key});

  @override
  State<testingSigninPage> createState() => _testingSigninPageState();
}

class _testingSigninPageState extends State<testingSigninPage> {
  // beginning of class

  // text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //  final TextEditingController _changePasswordController =
  //TextEditingController();
  //final TextEditingController _confirmPasswordController =
  //TextEditingController();
  //  final TextEditingController _OTPController = TextEditingController();

  // text controllers end
  // functions
  //

  //token saver
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token); // Save the token
  }

  //
  void _formSubmit() async {
    final formData = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
    };
    try {
      final response = await http.post(
        Uri.parse(SpringApi.loginUser),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      );
      if (response.statusCode == 200) {
        print("Success for Login method :) ");
        var token = response.body;

        await (saveToken(token));
        Navigator.push(context, MaterialPageRoute(builder: (_) => FeedPage()));
      } else {
        _usernameController.clear();
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username or Password wrong. Please try again."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error ${e}");
    }
  }

  // end of functions

  //  widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //start of scaffold
      body: Center(
        child: SingleChildScrollView(
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
              children: [
                SvgPicture.asset(AppVectors.logo, height: 110, width: 99.1),
                const SizedBox(height: 30),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login with your Username and Password",
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white38 : Colors.black38,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                _buildField(context, _usernameController, "Username"),
                const SizedBox(height: 15),
                _buildField(
                  context,
                  _passwordController,
                  "Password",
                  isPassword: true,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: context.isDarkMode
                              ? AppColors.darkPrimaryButton
                              : AppColors.lightPrimaryButton,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: BasicAppButton(
                        onPressed: () {
                          _formSubmit();
                        },
                        title: "Sign In",
                        height: 60,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't Have an Account? ",
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SingupPage()),
                        );
                      },
                      child: Text(
                        "Create An Account!",
                        style: TextStyle(
                          color: context.isDarkMode
                              ? AppColors.darkPrimaryButton
                              : AppColors.lightPrimaryButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      //end of scaffold
    );
  }

  // end of   widget

  // side widgets

  // build field widget
  /*Widget _buildField(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    String? errorText,
    bool isError = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),

        hintText: hint,
        hintStyle: TextStyle(
          color: context.isDarkMode ? Colors.white38 : Colors.black26,
        ),
      ),
    );
  }*/

  Widget _buildField(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    Color borderColor = context.isDarkMode
        ? AppColors.darkPrimaryButton
        : AppColors.lightPrimaryButton; // cool color depending on theme

    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.isDarkMode ? Colors.white38 : Colors.black26,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: borderColor.withOpacity(0.7), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: borderColor, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.redAccent, width: 3),
        ),
      ),
    );
  }

  // end of build field widget

  // end of side widgets
} // end of class
