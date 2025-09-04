import 'package:flutter/material.dart';
import 'package:lotto/widgets/app_header.dart';

import '../../widgets/app_drawer.dart';

class WalletLotto extends StatelessWidget {
  const WalletLotto({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF0593FF);
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppHeader(),
      drawer: AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0593FF), Color(0xFF4DBBFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/images/wallet1.png",
                        color: Colors.white,
                      )),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "ยอดเงินคงเหลือ",
                        style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "1000 บาท",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                "รายการ",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("สถานะ: ถูกรางวัล",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      SizedBox(height: 6),
                      Text("รหัสการเดิมพัน ABC123",
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SizedBox(height: 6),
                      Text("1,000,0000 บาท",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
