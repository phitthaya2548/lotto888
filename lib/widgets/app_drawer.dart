import 'package:flutter/material.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/pages/member/buy_lotto.dart';
import 'package:lotto/pages/member/profile_lotto.dart';
import 'package:lotto/pages/member/wallet_lotto.dart';
// import AuthService

import '../pages/home_lotto.dart';
import '../pages/check_lotto.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          final loggedIn = snapshot.data ?? false;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF007BFF)),
                child: Text(
                  'เมนู Lotto 888',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('หน้าหลัก'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LottoHome()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('ตรวจล็อตโต้'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckLotto()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('ซื้อล็อตเตอรี่'),
                enabled: loggedIn,
                onTap: loggedIn
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BuyTicket()),
                        );
                      }
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('วอลเล็ท'),
                enabled: loggedIn,
                onTap: loggedIn
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WalletLotto()),
                        );
                      }
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('โปรไฟล์'),
                enabled: loggedIn,
                onTap: loggedIn
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileLotto()),
                        );
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
