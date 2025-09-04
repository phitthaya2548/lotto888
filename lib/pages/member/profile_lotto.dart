import 'package:flutter/material.dart';
import 'package:lotto/pages/home_lotto.dart';
import 'package:lotto/pages/login.dart';
import 'package:lotto/pages/welcome_page.dart';
import 'package:lotto/widgets/app_header.dart';
import 'package:lotto/widgets/bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../auth_service.dart';


class ProfileLotto extends StatelessWidget {
  const ProfileLotto({super.key});

 Future<void> _logout(BuildContext context) async {
  await AuthService.clear();
  
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LottoHome()),
    (route) => false,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(),
      drawer: AppDrawer(),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.logout),
          label: const Text(
            "ออกจากระบบ",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
