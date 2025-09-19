import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lotto/config/config.dart';
import 'package:lotto/models/request/req_butlotto.dart';
import 'package:lotto/models/response/res_lotto.dart';
import 'package:lotto/models/response/res_profile.dart';
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

  List<Map<String, dynamic>> _mockTickets = [];

  String url = '';
  final _searchCtrl = TextEditingController();

  int _currentDrawId = 0;
  int? _userId = 0;
  int _currenNumber = 0;
  List<Map<String, dynamic>> allTickets = [];
  List<Map<String, dynamic>> viewTickets = [];
  var balance = 0.0;
  String _random6(Random r) => List.generate(6, (_) => r.nextInt(10)).join();
  final _money = NumberFormat('#,##0.00', 'th_TH');
  List<Map<String, dynamic>> _genMockTickets(int count) {
    final r = math.Random();
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    while (out.length < count) {
      final raw = _random6(r);
      if (seen.add(raw)) {
        out.add({
          'number': _format6(raw),
          'date': 'งวดปัจจุบัน',
          'price': 100,
        });
      }
    }
    return out;
  }

  Future<void> _loadmoney() async {
    try {
      final cfg = await Configuration.getConfig();
      final idStr = await AuthService.getId();
      final userId = idStr != null ? int.tryParse(idStr) : null;

      setState(() {
        url = (cfg['apiEndpoint'] ?? '')
            .toString()
            .replaceAll(RegExp(r'/+$'), '');
      });

      if (url.isEmpty || userId == null || userId <= 0) {
        ('invalid baseUrl/userId');
        return;
      }

      final uri = Uri.parse("$url/users/profile/$userId");
      final resp = await http.get(uri, headers: {'Accept': 'application/json'});
      if (resp.statusCode != 200) {
        ("fetch profile failed: ${resp.statusCode} ${resp.body}");
        return;
      }

      final data = responseRandomProfileFromJson(resp.body);
      setState(() {
        balance = data.wallet.balance.toDouble();
      });
      if (!mounted) return;
    } catch (e, st) {
      ('loadUser error: $e\n$st');
    }
  }

  @override
  void initState() {
    super.initState();

    () async {
      final config = await Configuration.getConfig();
      final id = await AuthService.getId();

      final mock = _genMockTickets(100);

      setState(() {
        url = (config['apiEndpoint'] ?? '')
            .toString()
            .replaceAll(RegExp(r'/+$'), '');
        _mockTickets = mock;
        allTickets = List<Map<String, dynamic>>.from(mock);
        viewTickets = List<Map<String, dynamic>>.from(mock);
        _userId = id != null ? int.tryParse(id) : null;
      });

      await _fetchLatest();
      await _loadmoney();
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
        dev.log(data.draw.id.toString());
        setState(() {
          _currentDrawId = data.draw.id + 1;
          _currenNumber = data.draw.drawNumber+1;
        });
      } else if (res.statusCode != 404) {
        dev.log('fetch test draw ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      dev.log('fetch latest exception: $e');
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
      userId: _userId!,
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
                  onPressed: () => Get.back(),
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

                  
                      setState(() {

                        _searchCtrl.clear();
                      });
                    } else {

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

  Future<bool> _ensureBuyable(String number6) async {
    try {
      final uri = Uri.parse('$url/tickets/check').replace(queryParameters: {
        'drawId': _currentDrawId.toString(),
        'number': number6,
      });

      final resp = await http.get(uri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final canBuy = data['canBuy'] == true;
        if (!canBuy) {
          setState(() {
            viewTickets = viewTickets.map((m) {
              final sixM = _toSixDigits((m['number'] as String?) ?? '');
              return (sixM == number6) ? {...m, 'soldOut': true} : m;
            }).toList();
          });
          Get.snackbar("ซื้อไม่ได้", "เลข ${_format6(number6)} ถูกซื้อแล้ว",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade700,
              colorText: Colors.white);
        }
        return canBuy;
      } else {
        Get.snackbar("ผิดพลาด", "เช็คสิทธิ์ซื้อไม่สำเร็จ (${resp.statusCode})",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
        return false;
      }
    } on TimeoutException {
      Get.snackbar("ช้าเกินไป", "การเชื่อมต่อหมดเวลา ลองใหม่อีกครั้ง",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar("เครือข่ายผิดพลาด", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return false;
    }
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
                        Text(
                          '${_money.format(balance)} ฿',
                          style: const TextStyle(
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

          
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: viewTickets.length,
                  itemBuilder: (_, i) {
                    final Map<String, dynamic> t =
                        viewTickets[i]; 
                    final String six = _toSixDigits(
                        (t['number'] as String?) ?? '');
                    final bool isSold = (t['soldOut'] == true);
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
                                        'งวดที่ $_currenNumber',
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

                                    // ✅ ซีด/ปิดการกด เมื่อเลขถูกซื้อแล้ว
                                    Opacity(
                                      opacity: isSold ? 0.4 : 1,
                                      child: IgnorePointer(
                                        ignoring: isSold,
                                        child: InkWell(
                                          onTap: () async {
                                            if (_currentDrawId <= 0) {
                                              Get.snackbar("ยังไม่พร้อม",
                                                  "กำลังโหลดงวดล่าสุด กรุณาลองใหม่อีกครั้ง",
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor:
                                                      Colors.orange.shade700,
                                                  colorText: Colors.white);
                                              return;
                                            }
                                            final six = _toSixDigits(
                                                (t['number'] as String?) ?? '');
                                            if (!RegExp(r'^\d{6}$')
                                                .hasMatch(six)) {
                                              Get.snackbar(
                                                "เลขไม่ถูกต้อง",
                                                "ต้องเป็นเลข 6 หลัก",
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                backgroundColor:
                                                    Colors.red.shade600,
                                                colorText: Colors.white,
                                              );
                                              return;
                                            }
                                            final canBuy =
                                                await _ensureBuyable(six);
                                            if (!canBuy) return;
                                            _confirmBuy(six,
                                                (t['price'] as int?) ?? 100);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(40),
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

  Future<void> _onRefresh() async {
    await _fetchLatest();
    await _loadmoney();
    if (mounted) {
      setState(() {
        _searchCtrl.clear();
        viewTickets = List<Map<String, dynamic>>.from(_mockTickets);
      });
    }
  }
}
