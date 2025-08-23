import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/core/configs/assets/app_vectors.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:julink/presentation/home/pages/feed/page/feed_page.dart';
import 'package:julink/presentation/home/pages/profile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;

  // Retrieve the token
  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('auth_token');
    });
  }
  // token retrieval

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FeedPage(),
      _token != null
          ? ProfilePage(token: _token!)
          : Container(child: Text("no token")),
    ];
    print(_token);
    return Scaffold(
      body: Row(
        children: [
          // Sidebar menu
          Material(
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.isDarkMode
                    ? AppColors.darkCardBackground
                    : AppColors.lightCardBackground,
              ),
              width: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(AppVectors.logo, height: 50),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.home_rounded, "Home", 0),
                  const SizedBox(height: 6),
                  _buildMenuItem(Icons.person_rounded, "Profile", 1),
                ],
              ),
            ),
          ),
          const SizedBox(width: 250),
          // Content area
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Material(
        elevation: isSelected ? 8.0 : 0.0,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.darkPrimaryButton
                : const Color.fromARGB(0, 255, 255, 255),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              context.isDarkMode
                  ? Icon(
                      icon,
                      size: isSelected ? 30.0 : 24.0,
                      color: Colors.white,
                    )
                  : Icon(
                      icon,
                      size: isSelected ? 30.0 : 24.0,
                      color: Colors.black,
                    ),
              const SizedBox(width: 12),
              context.isDarkMode
                  ? Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    )
                  : Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.black54,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
