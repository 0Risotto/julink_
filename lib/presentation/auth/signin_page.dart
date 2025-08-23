import 'dart:convert';
import 'package:julink/presentation/auth/signup_page.dart';
import 'package:julink/presentation/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/common/widgets/buttons/basic_app_button.dart';
import 'package:julink/core/api/spring_api.dart';
import 'package:julink/core/configs/assets/app_vectors.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  // text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // token saver
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

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
        var token = response.body;
        await saveToken(token);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        _usernameController.clear();
        _passwordController.clear();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username or Password wrong. Please try again."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // You can show a snackbar here too if you want
      debugPrint("Login error: $e");
    }
  }

  // --- NEW: Fake Forgot Password popup ---
  Future<void> _showForgotPasswordDialog() async {
    final otpCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final repeatCtrl = TextEditingController();

    bool submitting = false;
    bool showPass = false;
    bool showRepeat = false;

    String? otpError;
    String? passError;
    String? repeatError;

    Color borderColor = context.isDarkMode
        ? AppColors.darkPrimaryButton
        : AppColors.lightPrimaryButton;

    InputDecoration _decoration(
      String label, {
      String? errorText,
      Widget? suffix,
    }) {
      return InputDecoration(
        labelText: label,
        errorText: errorText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor.withOpacity(0.7), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 3),
        ),
        suffixIcon: suffix,
      );
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: !submitting,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            Future<void> _submit() async {
              if (submitting) return;
              // reset errors
              setS(() {
                otpError = null;
                passError = null;
                repeatError = null;
              });

              final otp = otpCtrl.text.trim();
              final pass = passCtrl.text;
              final repeat = repeatCtrl.text;

              bool hasError = false;
              if (otp.isEmpty) {
                otpError = 'Enter the OTP';
                hasError = true;
              } else if (otp.length < 4) {
                otpError = 'OTP looks too short';
                hasError = true;
              }
              if (pass.length < 6) {
                passError = 'Minimum 6 characters';
                hasError = true;
              }
              if (repeat != pass) {
                repeatError = 'Passwords do not match';
                hasError = true;
              }

              setS(() {}); // refresh error UI

              if (hasError) return;

              setS(() => submitting = true);
              await Future.delayed(
                const Duration(milliseconds: 600),
              ); // fake work
              // ignore: use_build_context_synchronously
              Navigator.of(ctx).pop(true);
            }

            return AlertDialog(
              title: const Text('Reset Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      enabled: !submitting,
                      decoration: _decoration('OTP', errorText: otpError),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passCtrl,
                      obscureText: !showPass,
                      enabled: !submitting,
                      decoration: _decoration(
                        'New Password',
                        errorText: passError,
                        suffix: IconButton(
                          onPressed: () => setS(() => showPass = !showPass),
                          icon: Icon(
                            showPass ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: repeatCtrl,
                      obscureText: !showRepeat,
                      enabled: !submitting,
                      decoration: _decoration(
                        'Repeat Password',
                        errorText: repeatError,
                        suffix: IconButton(
                          onPressed: () => setS(() => showRepeat = !showRepeat),
                          icon: Icon(
                            showRepeat
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reset'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If this were live, your password would be reset now 🎉',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: _showForgotPasswordDialog, // <-- NEW
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
                        onPressed: _formSubmit,
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
                          MaterialPageRoute(builder: (_) => const SingupPage()),
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
    );
  }

  Widget _buildField(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    Color borderColor = context.isDarkMode
        ? AppColors.darkPrimaryButton
        : AppColors.lightPrimaryButton;

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
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.redAccent, width: 3),
        ),
      ),
    );
  }
}
