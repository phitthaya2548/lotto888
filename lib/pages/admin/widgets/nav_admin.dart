import 'package:flutter/material.dart';
import 'package:lotto/pages/admin/home_addmin.dart';
import 'package:lotto/pages/admin/prize_darw_admin.dart';
import 'package:lotto/pages/admin/prize_darwresult_admin.dart';
import 'package:lotto/pages/admin/reset_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: ถ้าใช้ MemberShell ให้ import ให้ถูก หรือเปลี่ยนปลายทางเป็นหน้า Login
// import 'package:lotto/widgets/bottom_nav.dart'; // ตัวอย่างที่คุณใส่ไว้เดิม

class AdminNav extends StatefulWidget {
  const AdminNav({super.key});

  @override
  State<AdminNav> createState() => _AdminNavState();
}

class _AdminNavState extends State<AdminNav> {
  int _index = 0;

  // ต้องตรงกับจำนวนแท็บ
  final _navKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  final _appBarTitles = const ['หน้าหลัก', 'ออกรางวัล', 'ผลรางวัล', 'รีเซ็ท'];

  // root ของแต่ละแท็บ
  Widget _rootForTab(int i) {
    switch (i) {
      case 0:
        return HomeAdmin();
      case 1:
        return PrizeDarwAdmin();
      case 2:
        return PrizeDarwResultAdmin();
      default:
        return ResetAdmin();
    }
  }

  // Navigator แยกต่อแท็บ
  Widget _buildTabNavigator(int tabIndex) {
    return Navigator(
      key: _navKeys[tabIndex],
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => _rootForTab(tabIndex),
        settings: const RouteSettings(name: 'root'),
      ),
    );
  }

  // Back: pop ในแท็บก่อน
  Future<bool> _onWillPop() async {
    final nav = _navKeys[_index].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;

    Navigator.of(context).pop();
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
        icon: ImageIcon(AssetImage('assets/images/resultprize.png'), size: 24),
        activeIcon:
            ImageIcon(AssetImage('assets/images/resultprize.png'), size: 28),
        label: 'ผลรางวัล',
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 6,
          shadowColor: Colors.black26,
          surfaceTintColor: Colors.transparent,
          title: Text(_appBarTitles[_index]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: List.generate(
              4,
              (i) => Offstage(
                    offstage: _index != i,
                    child: _buildTabNavigator(i),
                  )),
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
                height: 72, // ← ปรับความสูงที่นี่
                child: BottomNavigationBar(
                  currentIndex: _index,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF0593FF), // สีตอนกด
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
