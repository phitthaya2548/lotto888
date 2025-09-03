import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lotto/pages/check_lotto.dart';
import 'package:lotto/pages/member/wallet_lotto.dart';

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

  late final _tabRoots = <Widget>[
    const LottoHome(),
    const BuyTicket(),
    const CheckLotto(),
    const WalletLotto(),
    const ProfileLotto(),
  ];

  void _onSelectTab(int i) {
    if (_index == i) {
      final nav = _navKeys[i].currentState!;
      while (nav.canPop()) nav.pop();
    } else {
      setState(() => _index = i);
    }
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
        bottomNavigationBar: Stack(
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
                    fontSize: selected ? 13 : 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.blue : Colors.grey,
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
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/Home.svg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                    ),
                    label: 'หน้าหลัก',
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      'assets/images/Ticket_use.svg',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/Ticket_use.svg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                    ),
                    label: 'ซื้อเลข',
                  ),

                  // ปล่อยแท็บกลางไว้ปกติ (มี label แสดงตาม NavigationBar)
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
                      color: Colors.blue,
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
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/Wallet.svg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                    ),
                    label: 'Wallet',
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      'assets/images/User_alt.svg',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/User_alt.svg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                    ),
                    label: 'ฉัน',
                  ),
                ],
              ),
            ),
            Positioned(
              top: -45,
              child: GestureDetector(
                onTap: () => _onSelectTab(2),
                child: Material(
                  elevation: 3,
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
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
    );
  }
}
