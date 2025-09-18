import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

// ==== ปรับ path ให้ตรงโปรเจกต์ของคุณ ====
import 'package:lotto/config/config.dart';
import 'package:lotto/models/response/res_lesson.dart'
    show ResponseRandomLesson, Draw, responseRandomLessonFromJson;
import 'package:lotto/models/response/res_lotto.dart'
    show ResponseRandomLotto, responseRandomLottoFromJson;

import 'package:lotto/widgets/app_drawer.dart';
import 'package:lotto/widgets/app_header.dart';

class CheckLotto extends StatefulWidget {
  const CheckLotto({Key? key}) : super(key: key);

  @override
  State<CheckLotto> createState() => _CheckLottoState();
}

class _CheckLottoState extends State<CheckLotto> {
  static const brand = Color(0xFF007BFF);

  // ===== App State =====
  String url = '';
  bool loading = false;

  // ผล “ล่าสุด” (หน้าแรกโหลด)
  ResponseRandomLotto? latest;

  // ผล “งวดที่เลือก” (ถ้าเลือกแล้วจะใช้ตัวนี้แสดงผล)
  ResponseRandomLotto? selectedResult;

  // Dropdown: รายการงวดจาก /draws/list
  String? _selectedDraw; // รูปแบบ value: yyyy-MM-dd#drawNumber
  List<DropdownMenuItem<String>> _drawItems = const [];
  List<Draw> _draws = [];

  // ช่องกรอกเลข 6 หลัก
  final List<String> digits = List.filled(6, '');

  // ===== helpers =====
  // ฟอร์แมตจำนวนเงิน 1,234,567
  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // yyyy-MM-dd
  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ใช้เป็น value ใน Dropdown เพื่อกันซ้ำ (วันที่ซ้ำได้ แต่ “วันที่#รอบ” ไม่ซ้ำ)
  String _drawValue(Draw d) => '${_dateStr(d.drawDate)}#${d.drawNumber}';

  // แยก yyyy-MM-dd#drawNumber ออกจาก value
  ({String date, int drawNumber}) _splitDrawValue(String value) {
    final parts = value.split('#'); // [date, drawNumber]
    final date = parts.isNotEmpty ? parts[0] : '';
    final drawNo = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return (date: date, drawNumber: drawNo);
  }

  // ชื่อส่วนหัวสำหรับผลที่แสดง (ล่าสุดหรือที่เลือก)
  String _selectedTitle() {
    if (_selectedDraw == null) return 'ผลรางวัลล่าสุด';
    final picked = _splitDrawValue(_selectedDraw!);
    return 'ผลรางวัลงวดที่ ${picked.drawNumber} (${picked.date})';
  }

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((c) async {
      final raw = (c['apiEndpoint'] ?? '').toString().trim();
      final normalized = raw.replaceAll(RegExp(r'/+$'), '');
      if (!mounted) return;
      setState(() => url = normalized);
      await _fetchLatest();
      await _fetchDrawList();
    });
  }

  // ===== API Calls =====

  // ดึง “ผลรางวัลล่าสุด” แสดงในหน้า (ใช้เมื่อยังไม่เลือกงวด)
  Future<void> _fetchLatest() async {
    if (url.isEmpty) return;
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('$url/draws'));
      if (res.statusCode == 200) {
        final data = responseRandomLottoFromJson(res.body);
        if (!mounted) return;
        setState(() {
          latest = data;
        });
      } else if (res.statusCode != 404) {
        log('fetch latest failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetch latest exception: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ดึง “รายการงวด” ไปลง Dropdown (กันซ้ำด้วยค่า yyyy-MM-dd#drawNumber)
  Future<void> _fetchDrawList() async {
    if (url.isEmpty) return;
    try {
      final res = await http.get(Uri.parse('$url/draws/list'));
      if (res.statusCode == 200) {
        final data = responseRandomLessonFromJson(res.body);

        final items = data.draws.map((d) {
          final date = _dateStr(d.drawDate);
          final value = _drawValue(d); // yyyy-MM-dd#drawNumber
          return DropdownMenuItem<String>(
            value: value,
            child: Text('งวดที่ ${d.drawNumber} ($date)'),
          );
        }).toList();

        setState(() {
          _draws = data.draws;
          _drawItems = items;
          _selectedDraw = items.isNotEmpty ? items.first.value : null;
        });

        for (final d in data.draws) {
          log("draw list -> รอบ ${d.drawNumber}, วันที่ ${_dateStr(d.drawDate)}");
        }

        // ถ้ามีค่าแรก ให้โหลดผลของงวดนั้นเป็นค่าเริ่มต้นด้วย (ถ้าอยากให้ “ล่าสุด” แสดงก่อน ให้คอมเมนต์บรรทัดนี้)
        if (_selectedDraw != null) {
          await _fetchBySelectedDraw(_selectedDraw!);
        }
      } else {
        log('fetchDrawList failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetchDrawList error: $e');
    }
  }

  // ดึง “ผลรางวัลตามงวดที่เลือก”
  Future<void> _fetchBySelectedDraw(String value) async {
    if (url.isEmpty) return;
    final picked = _splitDrawValue(value);

    setState(() => loading = true);
    try {
      final uri = Uri.parse('$url/draws/bydate').replace(queryParameters: {
        'date': picked.date,
        'drawNumber': picked.drawNumber.toString(),
      });
      log(picked.drawNumber.toString());
      final res = await http.get(uri);
      log('bydate ${res.statusCode} ${res.body}');

      if (res.statusCode == 200) {
        final data = responseRandomLottoFromJson(res.body);
        // ใช้งาน:
        final r = data.draw.results;
        final a = data.draw.amounts;
        setState(() {
          selectedResult = data; // เก็บไว้ใน state
        });
        // r.first, r.last3, a.prize1Amount, ...
      } else if (res.statusCode == 404) {
        if (!mounted) return;
        setState(() => selectedResult = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ไม่พบผลรางวัลของงวด ${picked.drawNumber} (${picked.date})')),
        );
      } else {
        log('fetch by selected failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetch by selected exception: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ===== Actions =====

  void _checkLotto() {
    final number = digits.join();

    if (_selectedDraw == null ||
        number.length != 6 ||
        digits.any((d) => d.isEmpty)) {
      _showGetDialog(
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณาเลือกงวด และกรอกเลขให้ครบ 6 หลัก',
        success: false,
      );
      return;
    }

    final showing = selectedResult ?? latest;
    if (showing == null) {
      _showGetDialog(
        title: 'ยังไม่มีข้อมูล',
        message: 'ยังไม่มีข้อมูลผลรางวัลของงวดที่เลือก',
        success: false,
      );
      return;
    }

    final r = showing.draw.results;
    final a = showing.draw.amounts;

    String? message;

    if (number == r.first) {
      message = "ถูกรางวัลที่ 1! ได้ ${_fmt(a.prize1Amount)} บาท";
    } else if (number == r.second) {
      message = "ถูกรางวัลที่ 2! ได้ ${_fmt(a.prize2Amount)} บาท";
    } else if (number == r.third) {
      message = "ถูกรางวัลที่ 3! ได้ ${_fmt(a.prize3Amount)} บาท";
    } else if (number.endsWith(r.last3)) {
      message = "ถูกรางวัลเลขท้าย 3 ตัว! ได้ ${_fmt(a.last3Amount)} บาท";
    } else if (number.endsWith(r.last2)) {
      message = "ถูกรางวัลเลขท้าย 2 ตัว! ได้ ${_fmt(a.last2Amount)} บาท";
    }

    if (message != null) {
      _showGetDialog(
        title: 'ยินดีด้วย 🎉',
        message: message,
        success: true,
      );
    } else {
      _showGetDialog(
        title: 'ไม่ถูกรางวัล',
        message: 'เสียใจด้วย ครั้งหน้าสู้ใหม่!',
        success: false,
      );
    }
  }

  void _showGetDialog({
    required String title,
    required String message,
    bool success = false,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
        fontWeight: FontWeight.w800,
        color: success ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (success)
            const Icon(Icons.emoji_events, size: 48)
          else
            const Icon(Icons.info_outline, size: 48),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      radius: 14,
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('ปิด'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // เลือก “ผลที่จะแสดง” — ถ้าเลือกงวดแล้วใช้ selectedResult, ไม่งั้นใช้ latest
    final showing = selectedResult ?? latest;
    final r = showing?.draw.results;
    final a = showing?.draw.amounts;

    final first = r?.first ?? '-';
    final last3 = r?.last3 ?? '-';
    final last2 = r?.last2 ?? '-';
    final second = r?.second ?? '-';
    final third = r?.third ?? '-';

    final prize1Amount = _fmt(a?.prize1Amount ?? 0);
    final prize2Amount = _fmt(a?.prize2Amount ?? 0);
    final prize3Amount = _fmt(a?.prize3Amount ?? 0);
    final last3Amount = _fmt(a?.last3Amount ?? 0);
    final last2Amount = _fmt(a?.last2Amount ?? 0);

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFEAF2FF),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedDraw != null) {
            await _fetchBySelectedDraw(_selectedDraw!);
          } else {
            await _fetchLatest();
          }
          await _fetchDrawList(); // ถ้าอยากรีเฟรชรายการงวดด้วย
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Column(
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),

              // ===== ฟอร์มตรวจสลาก =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Card(
                  color: const Color(0xFFD3EAFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "ตรวจผลสลากกินแบ่ง",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dropdown: เลือกงวด
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _drawItems.any((e) => e.value == _selectedDraw)
                              ? _selectedDraw
                              : null,
                          items: _drawItems,
                          decoration: InputDecoration(
                            labelText: "งวดวันที่",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Color(0xFF737A80), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onChanged: (v) async {
                            setState(() => _selectedDraw = v);
                            if (v != null) {
                              await _fetchBySelectedDraw(v);
                            } else {
                              setState(() => selectedResult = null);
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // ช่องกรอก 6 หลัก
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 40,
                              child: TextField(
                                maxLength: 1,
                                onChanged: (val) {
                                  if (val.isEmpty) {
                                    digits[index] = '';
                                    return;
                                  }
                                  digits[index] = val[0];
                                  if (index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "9",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.5),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF737A80), width: 2),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _checkLotto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brand,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              elevation: 4,
                            ),
                            child: const Text(
                              "ตรวจสลากกินแบ่ง",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== ส่วนแสดงผลรางวัล (ล่าสุด/งวดที่เลือก) =====
              Text(
                _selectedTitle(),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: brand),
              ),
              const SizedBox(height: 8),

              // รางวัลที่ 1
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text(
                            'รางวัลที่ 1',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              first,
                              style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: brand),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'รางวัลละ: $prize1Amount บาท',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // เลขท้าย 3 ตัว & 2 ตัว
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: brand,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)),
                              ),
                              child: const Center(
                                child: Text(
                                  'เลขท้าย 3 ตัว',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      last3,
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: brand),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'รางวัลละ: ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                        Text(
                                          last3Amount,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black87),
                                        ),
                                        const Text(
                                          ' บาท',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: brand,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)),
                              ),
                              child: const Center(
                                child: Text(
                                  'เลขท้าย 2 ตัว',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      last2,
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: brand),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'รางวัลละ: ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                        Text(
                                          last2Amount,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black87),
                                        ),
                                        const Text(
                                          ' บาท',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // รางวัลที่ 2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text(
                            'รางวัลที่ 2',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              second,
                              style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: brand),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'รางวัลละ: $prize2Amount บาท',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // รางวัลที่ 3
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text(
                            'รางวัลที่ 3',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              third,
                              style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: brand),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'รางวัลละ: $prize3Amount บาท',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
