import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lotto/pages/admin/home_addmin.dart';
import 'package:lotto/pages/admin/prize_darw_admin.dart';
import 'package:lotto/pages/admin/reset_admin.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../welcome_page.dart';

class AdminNav extends StatefulWidget {
  const AdminNav({super.key});

  @override
  State<AdminNav> createState() => _AdminNavState();
}

class _AdminNavState extends State<AdminNav> {
  int _index = 0;

  final _navKeys = List.generate(3, (_) => GlobalKey<NavigatorState>());

  Widget _rootForTab(int i) {
    switch (i) {
      case 0:
        return const HomeAdmin();
      case 1:
        return const PrizeDarwAdmin();
      case 2:
      default:
        return const ResetAdmin();
    }
  }

  Widget _buildTabNavigator(int tabIndex) {
    return Navigator(
      key: _navKeys[tabIndex],
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => _rootForTab(tabIndex),
        settings: const RouteSettings(name: 'root'),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final nav = _navKeys[_index].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  Future<void> _logout(BuildContext context) async {
  await AuthService.clear();

  Get.offAll(() => const WelcomePage());
}
  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/images/adhome.png'), size: 24),
        activeIcon: ImageIcon(AssetImage('assets/images/adhome.png'), size: 28),
        label: 'หน้าหลัก',
      ),
      const BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/images/prize.png'), size: 24),
        activeIcon: ImageIcon(AssetImage('assets/images/prize.png'), size: 28),
        label: 'ออกรางวัล',
      ),
      const BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/images/reset1.png'), size: 24),
        activeIcon: ImageIcon(AssetImage('assets/images/reset1.png'), size: 28),
        label: 'รีเซ็ท',
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // ❌ ไม่มี appBar แล้ว
        body: IndexedStack(
          index: _index,
          children: List.generate(
            items.length,
            (i) => Offstage(
              offstage: _index != i,
              child: _buildTabNavigator(i),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: SizedBox(
                height: 72,
                child: BottomNavigationBar(
                  currentIndex: _index,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF0593FF),
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                  items: items,
                  onTap: (i) => setState(() => _index = i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
