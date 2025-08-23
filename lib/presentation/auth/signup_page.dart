import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  // text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _oTPController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@ju\.edu\.jo$');

  // ---------- College dropdown state ----------
  int? _selectedCollegeId;
  List<_College> _colleges = [];
  bool _loadingColleges = false;
  void _showOtpDialog(String email) {
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
                _buildField(context, _oTPController, "OTP sent to mail"),
                const SizedBox(height: 16),
                BasicAppButton(
                  onPressed: () {
                    _verifyOtp(email, _oTPController.text.trim());
                  },
                  title: "Verify OTP",
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- helpers (web-safe host resolution) ---
  String get _apiAuthority {
    final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
    return '$host:8080';
  }

  Uri _apiUri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.http(_apiAuthority, normalized);
  }

  bool _isValidEmail(String email) => _emailRegex.hasMatch(email);
  bool _passwordMatch(String a, String b) => a == b;

  @override
  void initState() {
    super.initState();
    _fetchColleges();
  }

  Future<void> _fetchColleges() async {
    setState(() => _loadingColleges = true);
    try {
      final res = await http.get(_apiUri('/colleges'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        _colleges = data
            .map((e) => _College.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback (from your screenshot)
        _colleges = const [
          _College(id: 1, name: 'Engineering'),
          _College(id: 2, name: 'KASIT'),
          _College(id: 3, name: 'Medical School'),
          _College(id: 4, name: 'Literature'),
          _College(id: 5, name: 'Physical Education'),
        ];
      }
    } catch (_) {
      // Fallback on error as well
      _colleges = const [
        _College(id: 1, name: 'Engineering'),
        _College(id: 2, name: 'KASIT'),
        _College(id: 3, name: 'Medical School'),
        _College(id: 4, name: 'Literature'),
        _College(id: 5, name: 'Physical Education'),
      ];
    } finally {
      if (mounted) setState(() => _loadingColleges = false);
    }
  }

  //** form submission */
  Future<void> _formSubmit() async {
    if (_selectedCollegeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your college."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final formData = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "major": _majorController.text.trim(),
      "username": _usernameController.text.trim(),
      "confirmedPassword": _confirmPasswordController.text.trim(),
      "collegeId": _selectedCollegeId, // 👈 from dropdown
    };

    if (!_isValidEmail(formData["email"] as String)) {
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please use your @ju.edu.jo email."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_passwordMatch(
      formData["password"] as String,
      formData["confirmedPassword"] as String,
    )) {
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(SpringApi.createUser),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      );
      // ignore: avoid_print
      print('createUser -> ${response.statusCode} ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _sendOtp(_emailController.text.trim());
        // ignore: avoid_print
        print("Success for UserCreation; OTP sent. ${response.body}");
      } else {
        _emailController.clear();
        _usernameController.clear();
        setState(() => _selectedCollegeId = null);
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
      // ignore: avoid_print
      print("Error $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  //** end form submission */

  // ---------- OTP ----------
  Future<void> _sendOtp(String email) async {
    try {
      final response = await http.post(
        _apiUri('/entry/sendOTP'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      // ignore: avoid_print
      print('sendOTP -> ${response.statusCode} ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showOtpDialog(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send OTP"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("an error happened in otp sending $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _verifyOtp(String email, String OTP) async {
    try {
      final response = await http.post(
        _apiUri('/entry/checkOTPValidity'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": OTP}),
      );
      // ignore: avoid_print
      print('checkOTPValidity -> ${response.statusCode} ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("an error happened in otp verification $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  // ---------- end OTP ----------

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _majorController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _oTPController.dispose();
    super.dispose();
  }

  // UI
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
                    Expanded(child: _buildCollegeDropdown(context)),
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
                        onPressed: _formSubmit,
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
                          MaterialPageRoute(builder: (_) => const SigninPage()),
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
    );
  }

  // ---------- widgets ----------
  Widget _buildField(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    final Color borderColor = context.isDarkMode
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

  Widget _buildCollegeDropdown(BuildContext context) {
    final Color borderColor = context.isDarkMode
        ? AppColors.darkPrimaryButton
        : AppColors.lightPrimaryButton;

    return InputDecorator(
      decoration: InputDecoration(
        hintText: "Select College",
        hintStyle: TextStyle(
          color: context.isDarkMode ? Colors.white38 : Colors.black26,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: borderColor.withOpacity(0.7), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: borderColor, width: 3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<int>(
          value: _selectedCollegeId,
          isExpanded: true,
          decoration: const InputDecoration.collapsed(hintText: ''),
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text("Select College"),
          ),
          items: _loadingColleges
              ? const []
              : _colleges
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(c.name),
                        ),
                      ),
                    )
                    .toList(),
          onChanged: _loadingColleges
              ? null
              : (val) {
                  setState(() => _selectedCollegeId = val);
                },
        ),
      ),
    );
  }
}

// Simple model for colleges
class _College {
  final int id;
  final String name;
  const _College({required this.id, required this.name});
  factory _College.fromJson(Map<String, dynamic> json) =>
      _College(id: (json['id'] as num).toInt(), name: json['name'] as String);
}
