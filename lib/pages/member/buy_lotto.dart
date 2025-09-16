import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'package:http/http.dart' as http;
import 'package:lotto/config/config.dart';
import 'package:lotto/models/request/req_butlotto.dart';
import 'package:lotto/models/response/res_lotto.dart';
import 'package:lotto/pages/auth_service.dart';

import 'package:lotto/pages/member/my_lotto.dart';

import 'package:lotto/widgets/app_drawer.dart';
import 'package:lotto/widgets/app_header.dart';

class BuyTicket extends StatefulWidget {
  const BuyTicket({Key? key}) : super(key: key);

  @override
  State<BuyTicket> createState() => _BuyTicketState();
}

class _BuyTicketState extends State<BuyTicket> {
  static const brand = Color(0xFF007BFF);

  // mock เริ่มต้น (ถ้า server ว่าง)
  final List<Map<String, dynamic>> _mockTickets = const [
    {"number": "9 9 9 9 9 9", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 8", "date": "1 กันยายน 2568", "price": 100},
    {"number": "9 9 9 9 9 7", "date": "1 กันยายน 2568", "price": 100},
  ];

  String url = '';
  final _searchCtrl = TextEditingController();

  int _currentDrawId = 0;
  int? _userId = 0;

  List<Map<String, dynamic>> allTickets = [];
  List<Map<String, dynamic>> viewTickets = [];

  @override
  void initState() {
    super.initState();

    () async {
      final config = await Configuration.getConfig();
      final id = await AuthService.getId();

      setState(() {
        url = (config['apiEndpoint'] ?? '')
            .toString()
            .replaceAll(RegExp(r'/+$'), '');
        allTickets = List<Map<String, dynamic>>.from(_mockTickets);
        viewTickets = List<Map<String, dynamic>>.from(_mockTickets);
        _userId = id != null ? int.tryParse(id) : null;
      });
      await _fetchLatest();
    }();

    _searchCtrl.addListener(() => setState(() {}));
  }


  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLatest() async {
    if (url.isEmpty) return;

    try {
      final res = await http.get(Uri.parse('$url/draws'));
      if (res.statusCode == 200) {
        final data = responseRandomLottoFromJson(res.body);
        log(data.draw.id.toString());
        setState(() {
          _currentDrawId = data.draw.id+1;
        });
      } else if (res.statusCode != 404) {
        log('fetch test dreaw ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetch latest exception: $e');
    }
  }

  String _format6(String num6) {
    if (num6.length != 6) return num6;
    return '${num6[0]} ${num6[1]} ${num6[2]} ${num6[3]} ${num6[4]} ${num6[5]}';
  }

  String _toSixDigits(String spaced) => spaced.replaceAll(' ', '');

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  Future<void> _checkNumber() async {
    final number = _searchCtrl.text.replaceAll(' ', '').trim();

    if (url.isEmpty) {
      Get.snackbar("ผิดพลาด", "API endpoint ยังไม่พร้อม",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(number)) {
      Get.snackbar("เลขไม่ถูกต้อง", "กรุณากรอกเลข 6 หลัก เช่น 123456",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return;
    }

    _showLoading();

    try {
      final uri = Uri.parse('$url/tickets/check').replace(queryParameters: {
        'drawId': _currentDrawId.toString(),
        'number': number,
      });

      final resp = await http.get(uri, headers: {'Accept': 'application/json'});

      Get.back();

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final canBuy = data['canBuy'] == true;
        final status = data['currentStatus'];
        final drawDate = (data['drawDate'] as String?) ?? "งวดปัจจุบัน";

        if (canBuy) {
          setState(() {
            viewTickets = [
              {
                "number": _format6(number),
                "date": drawDate,
                "price": 100,
              }
            ];
          });

          Get.snackbar(
            "พร้อมซื้อ",
            "เลข $number ว่างอยู่ กดไอคอนตะกร้าเพื่อยืนยันการซื้อ",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            "ซื้อไม่ได้",
            "เลข $number ถูกซื้อแล้ว${status != null ? " (สถานะ: $status)" : ""}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade700,
            colorText: Colors.white,
          );
        }
      } else {
        String msg = 'Server error: ${resp.statusCode}';
        try {
          final m = jsonDecode(resp.body);
          if (m is Map && m['message'] is String) msg = m['message'];
        } catch (_) {}
        Get.snackbar("ผิดพลาด", msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("เครือข่ายผิดพลาด", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    }
  }

  Future<bool> _buyLotto({
    required String number6,
    required int price,
  }) async {
    if (url.isEmpty) {
      Get.snackbar("ผิดพลาด", "API endpoint ยังไม่พร้อม",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return false;
    }

    if (_userId == null || _userId == 0) {
      Get.snackbar("ยังไม่ได้เข้าสู่ระบบ", "กรุณาเข้าสู่ระบบก่อนทำรายการซื้อ",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white);
      return false;
    }

    final req = RequestBuylotto(
      drawId: _currentDrawId,
      userId: _userId!, // ใช้ user จาก session
      number: number6,
      price: price,
    );

    try {
      final resp = await http.post(
        Uri.parse('$url/tickets/buy-number'),
        headers: const {
          "Content-Type": "application/json; charset=utf-8",
          "Accept": "application/json",
        },
        body: requestBuylottoToJson(req),
      );

      // รองรับกรณี race condition — ซื้อชนกัน ให้ถือว่าไม่สำเร็จและแจ้งผู้ใช้
      if (resp.statusCode == 409) {
        Get.snackbar(
          "ซื้อไม่สำเร็จ",
          "เลขนี้ถูกซื้อไปก่อนหน้าแล้ว",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return false;
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final success = (data is Map &&
            (data['success'] == true || data['status'] == 'ok'));
        if (success) return true;

        // ถ้า backend ไม่ส่ง success มาแต่ response 200/201
        return true;
      } else {
        String msg = 'Server error: ${resp.statusCode}';
        try {
          final m = jsonDecode(resp.body);
          if (m is Map && m['message'] is String) msg = m['message'];
        } catch (_) {}
        Get.snackbar("ซื้อไม่สำเร็จ", msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar("เครือข่ายผิดพลาด", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return false;
    }
  }

  Future<void> _confirmBuy(String number6, int price) async {
    // ยืนยันก่อนซื้อ
    await Get.defaultDialog(
      title: 'ยืนยันการซื้อ',
      titleStyle: const TextStyle(fontWeight: FontWeight.w800),
      radius: 14,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Text('เลขที่เลือก: ${_format6(number6)}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('งวดที่ $_currentDrawId',
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('ราคา: $price บาท',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(), // ยกเลิก
                  child: const Text('ยกเลิก'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                  ),
                  onPressed: () async {
                    // ปิด dialog ยืนยันก่อนแล้วค่อยโชว์โหลด
                    Get.back();
                    _showLoading();
                    final ok = await _buyLotto(number6: number6, price: price);
                    Get.back();

                    if (ok) {
                      Get.snackbar(
                        "สำเร็จ 🎉",
                        "ซื้อตั๋วเลข ${_format6(number6)} สำเร็จ",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                      );

                      // อัปเดต UI หลังซื้อ (ตัวอย่าง: เพิ่มเข้า "สลากของฉัน" / ล้างผลค้นหา)
                      setState(() {
                        // ใส่ตามจริงถ้าต้องการเก็บรายการที่ซื้อ
                        _searchCtrl.clear();
                      });
                    } else {
                      // ล้มเหลวมี snackbar ไปแล้ว
                    }
                  },
                  child: const Text('ยืนยันซื้อ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const AppHeader(),
      backgroundColor: const Color(0xFFEAF2FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // แถบยอดเงิน (ยังเป็น mock)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007BFF), Color(0xFF6EC9FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
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
                        const SizedBox(width: 6),
                        const Text(
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
          
              // ปุ่ม "สลากของฉัน"
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyTicket(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
              // ช่องกรอก "เลข 6 หลัก" + ปุ่มแว่น
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
                      controller: _searchCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onSubmitted: (_) => _checkNumber(),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: 'กรอกเลข 6 หลัก เช่น 123456',
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search,
                                    color: Colors.black45, size: 28),
                                onPressed: _checkNumber,
                              ),
                              if (_searchCtrl.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.black45, size: 22),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 12),
          
              // รายการสลาก (ตัวอย่างจาก viewTickets)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: viewTickets.length,
                  itemBuilder: (_, i) {
                    final t = viewTickets[i];
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
                                      (t['number'] ?? '') as String,
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
                                        'งวดที่ $_currentDrawId',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black.withOpacity(.6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        (t['date'] ?? '') as String,
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
                                    Text(
                                      '${t['price'] ?? 0} บาท',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
          
                                        final six = _toSixDigits(
                                          (t['number'] as String?) ?? '',
                                        );
                                        if (!RegExp(r'^\d{6}$').hasMatch(six)) {
                                          Get.snackbar(
                                            "เลขไม่ถูกต้อง",
                                            "ต้องเป็นเลข 6 หลัก",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red.shade600,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }
                                        _confirmBuy(
                                            six, (t['price'] as int?) ?? 100);
          
                                     
          
                                      },
                                      borderRadius: BorderRadius.circular(40),
                                      child: const CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white,
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images/basket.png'),
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.contain,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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


  Future<void> _onRefresh() async {

  await _fetchLatest();

  if (mounted) {
    setState(() {
      _searchCtrl.clear();
      viewTickets = List<Map<String, dynamic>>.from(_mockTickets);
    });
  }
}

}
