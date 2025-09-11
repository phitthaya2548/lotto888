import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lotto/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHeaderAdmin extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderAdmin({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const WelcomePage());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF007BFF),
      title: Row(
        children: [
          Image.asset(
            "assets/images/smalllogo.png",
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 8),
          const Text(
            "Lotto 888",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
  IconButton(
    icon: Image.asset(
      "assets/images/solar--logout-2-outline.png",
      width: 28,
      height: 28,
      color: Colors.white,
    ),
    tooltip: "ออกจากระบบ",
    onPressed: () => _logout(context),
  ),
],

    );
  }
}
