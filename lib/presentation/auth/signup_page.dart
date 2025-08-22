import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/common/widgets/buttons/basic_app_button.dart';
import 'package:julink/core/api/spring_api.dart';
import 'package:julink/core/configs/assets/app_vectors.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:julink/presentation/auth/signin_page.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  // beginning of class

  // text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _OTPController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@ju\.edu\.jo$');

  // text controllers end
  // functions
  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  bool _passwordMatch(String password, String reEnteredPassword) {
    return password == reEnteredPassword;
  }

  //** this is for the form submittion function */
  void _formSubmit() async {
    final formData = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "major": _majorController.text.trim(),
      "username": _usernameController.text.trim(),
      "confirmedPassword": _confirmPasswordController.text.trim(),
      "collegeId": "1",
    };
    if (!_isValidEmail(formData["email"]!)) {
      _emailController.clear();
      print("invalid email yuh");
      return;
    }
    if (!_passwordMatch(
      formData["password"]!,
      formData["confirmedPassword"]!,
    )) {
      print("passwords dont match");
      _confirmPasswordController.clear();
    }
    try {
      final reponse = await http.post(
        Uri.parse(SpringApi.createUser),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      );
      if (reponse.statusCode == 200) {
        print(
          "Success for UserCreation method now for the Otp :) ${reponse.body}",
        );

        _sendOtp(_emailController.text.trim());
      } else {
        _emailController.clear();
        _collegeController.clear();
        _usernameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Username or email is already taken. Please try another.",
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error ${e}");
    }
  }

  //** this is the end of the form submission */

  // otp functionality
  Future<void> _sendOtp(String email) async {
    try {
      final reponse = await http.post(
        Uri.parse(SpringApi.sendOTP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (reponse.statusCode == 200) {
        _showOtpDialog(email);
      }
    } catch (e) {
      print("an error happened in otp sending ${e}");
    }
  }

  Future<void> _verifyOtp(String email, String OTP) async {
    try {
      final reponse = await http.post(
        Uri.parse(SpringApi.checkOTP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": OTP}),
      );
      if (reponse.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SigninPage()),
        );
      }
    } catch (e) {
      print("an error happened in otp sending ${e}");
    }
  }

  void _showOtpDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(16),
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
                _buildField(context, _OTPController, "OTP sent to mail"),
                BasicAppButton(
                  onPressed: () {
                    _verifyOtp(email, _OTPController.text.trim());
                  },
                  title: "Verify OTP",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  //otp functionality

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
                  "Login with your universty email and password",
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white38 : Colors.black38,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        context,
                        _firstNameController,
                        "First Name",
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _buildField(
                        context,
                        _lastNameController,
                        "Last Name",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        context,
                        _collegeController,
                        "College",
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _buildField(
                        context,
                        _majorController,
                        "Major Name",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField(context, _usernameController, "Username"),

                const SizedBox(height: 10),

                _buildField(context, _emailController, "email"),
                const SizedBox(height: 10),
                _buildField(
                  context,
                  _passwordController,
                  "password",
                  isPassword: true,
                ),
                const SizedBox(height: 10),

                _buildField(
                  context,
                  _confirmPasswordController,
                  "Repeat Password",
                  isPassword: true,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: BasicAppButton(
                        onPressed: () {
                          _formSubmit();
                        },
                        title: "Sign Up",
                        height: 60,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already Have an Account?",
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SigninPage()),
                        );
                      },
                      child: Text(
                        "Sign In!",
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
    //String? errorText,
    //bool isError = false,
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
