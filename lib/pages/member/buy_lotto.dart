import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lotto/widgets/app_drawer.dart';
import 'package:lotto/widgets/app_header.dart';

class BuyTicket extends StatefulWidget {
  const BuyTicket({Key? key}) : super(key: key);

  @override
  State<BuyTicket> createState() => _BuyTicketState();
}

class _BuyTicketState extends State<BuyTicket> {
  static const brand = Color(0xFF007BFF);

  final List<Map<String, dynamic>> tickets = [
    {"number": "9 9 9 9 9 9", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 8", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 7", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 7", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 7", "date": "1 กันยายน 2568", "price": 100},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const AppHeader(),
      backgroundColor: const Color(0xFFEAF2FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF007BFF), Color(0xFF6EC9FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/wallet1.png',
                        color: Colors.white,
                        width: 28,
                        height: 28,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "1000฿",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: brand, width: 2),
                          backgroundColor: Colors.white,
                          foregroundColor: brand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/list.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        label: const Text(
                          'สลากของฉัน',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: brand,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lotto',
                    style: TextStyle(
                      color: brand,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'ค้นหาสลาก...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: brand, width: 1.5),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: const Icon(Icons.search,
                            color: Colors.black45, size: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tickets.length,
                itemBuilder: (_, i) {
                  final t = tickets[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFADDCFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'สลากลอตโต้ 888',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    t['number'],
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'งวดที่ xx',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      t['date'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 85,
                            decoration: BoxDecoration(
                              color: brand,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/logo1.png',
                                    color: Colors.white,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '100 บาท',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                        showBuyDialog();
                                    },
                                    borderRadius: BorderRadius.circular(40),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.white,
                                      child: Image.asset(
                                        'assets/images/basket.png',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    
  }
void showBuyDialog() {
  Get.defaultDialog(
    title: "",
    titlePadding: EdgeInsets.zero,
    contentPadding: const EdgeInsets.all(16),
    radius: 12,
    content: Column(
      children: [
        const Text(
          "ต้องการซื้อสลากลอตเตอรี่ 888",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          "เลข 999999",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          "ราคา 100 บาท",
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  "สำเร็จ",
                  "คุณยืนยันการซื้อเรียบร้อยแล้ว",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 2),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "ยืนยัน",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  "ยกเลิก",
                  "คุณได้ยกเลิกรายการนี้",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 2),
                  icon: const Icon(Icons.cancel, color: Colors.white),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "ยกเลิก",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}
