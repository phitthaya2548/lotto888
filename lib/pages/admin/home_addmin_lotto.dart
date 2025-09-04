import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAddminLotto extends StatelessWidget {
  const HomeAddminLotto({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // // กลับไปหน้า Login (แทนที่ stack ไม่ให้กดย้อนกลับได้)
    // Navigator.pushNamedAndRemoveUntil(context, ๖๗, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: const Center(
        child: Text('HomeAddminLotto'),
      ),
    );
  }
}
