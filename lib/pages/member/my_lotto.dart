import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lotto/widgets/app_drawer.dart';

class MyTicket extends StatefulWidget {
  const MyTicket({Key? key}) : super(key: key);

  @override
  State<MyTicket> createState() => _MyTicketState();
}

class _MyTicketState extends State<MyTicket> {
  static const brand = Color(0xFF007BFF);
  String? _selectedDraw;

  final List<DropdownMenuItem<String>> _drawItems = const [
    DropdownMenuItem(value: "2025-09-01", child: Text("1 กันยายน 2568")),
    DropdownMenuItem(value: "2025-08-16", child: Text("16 สิงหาคม 2568")),
  ];

  final List<Map<String, dynamic>> tickets = [
    {"number": "9 9 9 9 9 9", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 8", "date": "1 กันยายน 2568", "price": 100},
    // {"number": "9 9 9 9 9 7", "date": "1 กันยายน 2568", "price": 100},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'สลากของฉัน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedDraw,
                items: _drawItems,
                decoration: InputDecoration(
                  labelText: "งวดวันที่ dd mmmm yyyy",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 115, 122, 128),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _selectedDraw = v),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: tickets.length,
                itemBuilder: (_, i) {
                  final t = tickets[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
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
                                          fontWeight: FontWeight.w900,
                                          fontSize: 28,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                              child: const Text(
                                'ยังไม่ประกาศ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showBuyDialog();
                              }, // disabled
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Color(0xFF34C759),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48, vertical: 5),
                              ),
                              child: const Text(
                                'ขึ้นเงิน',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void showBuyDialog({Duration autoClose = const Duration(seconds: 10)}) {
    Get.dialog(
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: 12, sigmaY: 12), // ปรับความแรงได้
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "ยินดีด้วย คุณถูกรางวัล XX",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "คุณ XXXXXXXX คุณเป็นเศรษฐีแล้ว",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "เป็นเงินรางวัล 600,000,000 บาท",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: autoClose,
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300, // สีพื้นหลัง
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green), // สี progress
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "ปิด",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 255, 0, 0)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false, // กันเผลอกดนอกกรอบแล้วปิด
      barrierColor:
          Colors.transparent, // ต้องโปร่งใสเพื่อให้ BackdropFilter ทำงาน
    );

    Future.delayed(autoClose, () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }
}
