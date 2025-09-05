import 'package:flutter/material.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/pages/home_lotto.dart';
import 'package:lotto/widgets/app_drawer.dart';
import 'package:lotto/widgets/app_header.dart';

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
      appBar: AppHeader(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person,
                                    size: 40, color: Colors.black54),
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "ชื่อ >",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "รหัสสมาชิก : L1234",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 100,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/images/bitcoin.png',
                                        width: 32, height: 32),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "0",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const Text("พอยต์"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/images/tiket1.png',
                                        width: 32, height: 32),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "0",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const Text("สลากของฉัน"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/images/copon.png',
                                        width: 32, height: 32),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "0",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const Text("คูปอง"),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('คูปองส่วนลด',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                ),
                Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Image.asset('assets/images/copon.png',
                            width: 80, height: 80),
                        const SizedBox(width: 12),
                        const Text(
                          "เก็บคูปอง",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: const Text("ใส่รหัสคูปอง"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ข้อมูลมาชิก',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/account_circle.png',
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "ข้อมูลส่วนตัว",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/Frame.png',
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "ที่อยู่",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _logout(context);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/leave.png',
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "ออกจากระบบ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
