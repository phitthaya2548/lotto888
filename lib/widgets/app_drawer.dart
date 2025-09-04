import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2196F3)),
            child: Text('เมนู Lotto 888',
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          ListTile(leading: Icon(Icons.home), title: Text('หน้าหลัก')),
          ListTile(
              leading: Icon(Icons.receipt_long), title: Text('ตรวจล็อตโต้')),
          ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('ซื้อล็อตเตอรี่')),
          ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('วอลเล็ท')),
          ListTile(leading: Icon(Icons.person), title: Text('โปรไฟล์')),
        ],
      ),
    );
  }
}
