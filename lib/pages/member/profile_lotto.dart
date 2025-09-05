import 'package:flutter/material.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/pages/home_lotto.dart';
import 'package:lotto/widgets/app_drawer.dart';

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
      backgroundColor: Colors.blue[50],
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          SizedBox(height: 8),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 40, color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text("ชื่อ >",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          Text("รหัสสมาชิก : L1234",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),

                  // กล่องเงินของฉัน (สีขาว) ลอยทับลงมา
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 140,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.credit_card, size: 40),
                              SizedBox(width: 10),
                              Text(
                                "เงินของฉัน\n0.00",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _Stat(
                                  icon: Icons.attach_money,
                                  line1: '0',
                                  line2: 'พอยต์'),
                              _Stat(
                                  icon: Icons.confirmation_number,
                                  line1: '0',
                                  line2: 'สลากของฉัน'),
                              _Stat(
                                  icon: Icons.percent,
                                  line1: '0',
                                  line2: 'คูปอง'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== คูปองส่วนลด =====
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.local_offer, size: 40),
                title: const Text("คูปองส่วนลด"),
                subtitle: ElevatedButton(
                  onPressed: () {},
                  child: const Text("ใส่รหัสคูปอง"),
                ),
                trailing: const Text("เก็บคูปอง"),
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("ข้อมูลส่วนตัว"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text("ที่อยู่"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextButton(
                  onPressed: () {
                    _logout(context);
                  },
                  child: Text("ออกจากระบบ")),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String line2;
  const _Stat({required this.icon, required this.line1, required this.line2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        Text(line1, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(line2, textAlign: TextAlign.center),
      ],
    );
  }
}
