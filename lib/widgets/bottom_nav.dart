import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lotto/pages/check_lotto.dart';
import 'package:lotto/pages/member/wallet_lotto.dart';
import 'package:lotto/pages/welcome_page.dart';

import '../pages/auth_service.dart';
import '../pages/home_lotto.dart';
import '../pages/member/buy_lotto.dart';
import '../pages/member/profile_lotto.dart';

class MemberShell extends StatefulWidget {
  const MemberShell({super.key});
  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  int _index = 0;

  final _navKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());
  final Set<int> _protectedTabs = {2, 3, 4};
  late final _tabRoots = <Widget>[
    const LottoHome(),
    const CheckLotto(),
    const BuyTicket(),
    WalletLotto(),
    const ProfileLotto(),
  ];
 void _askLogin() {
  Get.defaultDialog(
    title: 'ยังไม่ได้เข้าสู่ระบบ',
    middleText: 'คุณต้องล็อกอินก่อนเพื่อเข้าใช้งานเมนูนี้',
    barrierDismissible: false,
    titleStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF007BFF),
    ),
    middleTextStyle: const TextStyle(
      fontSize: 18,
      color: Colors.black87,
    ),
    backgroundColor: Colors.white,
    radius: 12,
    actions: [
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF007BFF)),
          foregroundColor: const Color(0xFF007BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Get.back();
        },
        child: const Text('ยกเลิก'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () {
          Get.back();
          Get.to(const WelcomePage());
        },
        child: const Text(
          'ไปหน้า Login',
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}


 Future<void> _onSelectTab(int i) async {
  if (_index == i) {
    final nav = _navKeys[i].currentState;
    if (nav != null) {
      while (nav.canPop()) nav.pop();
    }
    return;
  }

  if (_protectedTabs.contains(i)) {
    final ok = await AuthService.isLoggedIn();
    if (!ok) {
      _askLogin();
      return;
    }
  }

  if (!mounted) return;
  setState(() => _index = i);
}

  Widget _buildTabNavigator(int i) {
    return Navigator(
      key: _navKeys[i],
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => _tabRoots[i],
        settings: settings,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final current = _navKeys[_index].currentState!;
    if (current.canPop()) {
      current.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _index,
            children: List.generate(_tabRoots.length, _buildTabNavigator),
          ),
        ),
        bottomNavigationBar: Material(
          elevation: 18,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: Colors.transparent,
                  labelTextStyle: MaterialStateProperty.resolveWith((states) {
                    final selected = states.contains(MaterialState.selected);
                    return TextStyle(
                      fontSize: selected ? 15 : 14,
                      fontWeight: FontWeight.bold,
                      color: selected ? Color(0xFF007BFF) : Colors.grey,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 72,
                  selectedIndex: _index,
                  onDestinationSelected: _onSelectTab,
                  destinations: [
                    NavigationDestination(
                      icon: SvgPicture.asset(
                        'assets/images/Home.svg',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                      ),
                      selectedIcon: SvgPicture.asset(
                        'assets/images/Home.svg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF007BFF), BlendMode.srcIn),
                      ),
                      label: 'หน้าหลัก',
                    ),
                    NavigationDestination(
                      icon: SvgPicture.asset(
                        'assets/images/Ticket_use.svg',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                      ),
                      selectedIcon: SvgPicture.asset(
                        'assets/images/Ticket_use.svg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF007BFF), BlendMode.srcIn),
                      ),
                      label: 'ตรวจลอตโต้',
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        'assets/images/Logo.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        color: Colors.grey,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      selectedIcon: Image.asset(
                        'assets/images/Logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        color: Color(0xFF007BFF),
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      label: 'ซื้อลอตโต้',
                    ),
                    NavigationDestination(
                        icon: SvgPicture.asset(
                          'assets/images/Wallet.svg',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(
                              Colors.grey, BlendMode.srcIn),
                        ),
                        selectedIcon: SvgPicture.asset(
                          'assets/images/Wallet.svg',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(
                              Color(0xFF007BFF), BlendMode.srcIn),
                        ),
                        label: 'วอเล็ท'),
                    NavigationDestination(
                      icon: SvgPicture.asset(
                        'assets/images/User_alt.svg',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                      ),
                      selectedIcon: SvgPicture.asset(
                        'assets/images/User_alt.svg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF007BFF), BlendMode.srcIn),
                      ),
                      label: 'ฉัน',
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -50,
                child: InkWell(
                  onTap: () => _onSelectTab(2),
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/logo1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
