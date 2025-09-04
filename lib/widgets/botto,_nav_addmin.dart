import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lotto/pages/admin/home_addmin_lotto.dart';
import 'package:lotto/pages/check_lotto.dart';
import 'package:lotto/pages/member/wallet_lotto.dart';

import '../pages/auth_service.dart';
import '../pages/home_lotto.dart';
import '../pages/login.dart';
import '../pages/member/buy_lotto.dart';
import '../pages/member/profile_lotto.dart';

class AdminNav extends StatefulWidget {
  const AdminNav({super.key});
  @override
  State<AdminNav> createState() => _AdminNavState();
}

class _AdminNavState extends State<AdminNav> {
  int _index = 0;

  final _navKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());
 final Set<int> _protectedTabs = {2, 3, 4};
  late final _tabRoots = <Widget>[
    HomeAddminLotto()
  ];

   Future<void> _onSelectTab(int i) async {
    if (_index == i) {
      final nav = _navKeys[i].currentState!;
      while (nav.canPop()) nav.pop();
      return;
    }
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
                  
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
