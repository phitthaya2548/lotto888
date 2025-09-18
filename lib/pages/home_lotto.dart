import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;
// ==== ปรับ path ให้ตรงโปรเจกต์ของคุณ ====
import 'package:lotto/config/config.dart';
import 'package:lotto/models/response/res_lesson.dart'
    show ResponseRandomLesson, Draw, responseRandomLessonFromJson;
import 'package:lotto/models/response/res_lotto.dart'
    show ResponseRandomLotto, responseRandomLottoFromJson;

import '../widgets/app_drawer.dart';

class LottoHome extends StatefulWidget {
  const LottoHome({Key? key}) : super(key: key);

  @override
  State<LottoHome> createState() => _LottoHomeState();
}

class _LottoHomeState extends State<LottoHome> {
  static const brand = Color(0xFF007BFF);

  // ---- State หลัก ----
  String url = '';
  bool loading = false;

  // Dropdown: งวดที่เลือก (value = yyyy-MM-dd#drawNumber)
  String? _selectedDrawValue;
  List<DropdownMenuItem<String>> _drawItems = const [];
  List<Draw> _draws = [];

  // ผลรางวัล (ตามงวดที่เลือก)
  ResponseRandomLotto? selectedResult;

  // ช่องกรอกเลข 6 หลัก
  final List<String> digits = List.filled(6, '');

  // ===== helpers =====
  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // value สำหรับ Dropdown (กันซ้ำวันเดิมแต่คนละรอบ)
  String _drawValue(Draw d) => '${_dateStr(d.drawDate)}#${d.drawNumber}';

  ({String date, int drawNumber}) _splitDrawValue(String value) {
    final parts = value.split('#'); // [date, drawNo]
    final date = parts.isNotEmpty ? parts[0] : '';
    final drawNo = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return (date: date, drawNumber: drawNo);
  }

  String _title() {
    if (_selectedDrawValue == null) return 'เลือกงวดเพื่อแสดงผลรางวัล';
    final picked = _splitDrawValue(_selectedDrawValue!);
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
      await _fetchDrawList();
    });
  }

  void _checkLotto() {
    final number = digits.join();

    if (digits.any((d) => d.isEmpty) || number.length != 6) {
      Get.defaultDialog(
        title: "ข้อมูลไม่ครบ",
        content: const Text("กรุณากรอกเลขให้ครบ 6 หลัก"),
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("ปิด"),
        ),
      );
      return;
    }

    if (_selectedDrawValue == null) {
      Get.defaultDialog(
        title: "ยังไม่ได้เลือกงวด",
        content: const Text("กรุณาเลือกงวดวันที่ก่อนตรวจสลาก"),
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("ปิด"),
        ),
      );
      return;
    }

    if (selectedResult == null) {
      Get.defaultDialog(
        title: "ยังไม่มีข้อมูล",
        content: const Text("ยังไม่มีผลรางวัลของงวดที่เลือก"),
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("ปิด"),
        ),
      );
      return;
    }

    final r = selectedResult!.draw.results;
    final a = selectedResult!.draw.amounts;

    String? message;
    String title = "ไม่ถูกรางวัล";
    bool success = false;

    if (number == r.first) {
      title = "ยินดีด้วย 🎉";
      message = "ถูกรางวัลที่ 1! ได้ ${_fmt(a.prize1Amount)} บาท";
      success = true;
    } else if (number == r.second) {
      title = "ยินดีด้วย 🎉";
      message = "ถูกรางวัลที่ 2! ได้ ${_fmt(a.prize2Amount)} บาท";
      success = true;
    } else if (number == r.third) {
      title = "ยินดีด้วย 🎉";
      message = "ถูกรางวัลที่ 3! ได้ ${_fmt(a.prize3Amount)} บาท";
      success = true;
    } else if (number.endsWith(r.last3)) {
      title = "ยินดีด้วย 🎉";
      message = "ถูกรางวัลเลขท้าย 3 ตัว! ได้ ${_fmt(a.last3Amount)} บาท";
      success = true;
    } else if (number.endsWith(r.last2)) {
      title = "ยินดีด้วย 🎉";
      message = "ถูกรางวัลเลขท้าย 2 ตัว! ได้ ${_fmt(a.last2Amount)} บาท";
      success = true;
    }

    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: success ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(success ? Icons.emoji_events : Icons.info_outline,
              size: 48,
              color:
                  success ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C)),
          const SizedBox(height: 8),
          Text(
            message ?? "เสียใจด้วย ครั้งหน้าสู้ใหม่!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      radius: 14,
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text("ปิด"),
      ),
    );
  }

  Future<void> _fetchDrawList() async {
    if (url.isEmpty) return;
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('$url/draws/list'));
      if (res.statusCode == 200) {
        final data = responseRandomLessonFromJson(res.body);

        final items = data.draws.map((d) {
          final date = _dateStr(d.drawDate);
          final value = _drawValue(d);
          return DropdownMenuItem<String>(
            value: value,
            child: Text('งวดที่ ${d.drawNumber} ($date)'),
          );
        }).toList();

        setState(() {
          _draws = data.draws;
          _drawItems = items;
          // ให้ผู้ใช้เลือกเอง (ไม่ auto เลือก)
          _selectedDrawValue = null;
          selectedResult = null;
        });
      } else {
        log('list failed: ${res.statusCode} ${res.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('โหลดรายการงวดไม่สำเร็จ')),
          );
        }
      }
    } catch (e) {
      log('list exception: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _fetchBySelectedDraw(String value) async {
    if (url.isEmpty) return;
    final picked = _splitDrawValue(value);

    setState(() {
      loading = true;
      selectedResult = null; // เคลียร์ก่อน เพื่อไม่ให้โชว์ค่าเก่า
    });

    try {
      final uri = Uri.parse('$url/draws/bydate').replace(queryParameters: {
        'date': picked.date,
        'drawNumber': picked.drawNumber.toString(),
      });
      final res = await http.get(uri);
      log('bydate ${res.statusCode} ${res.body}');
      if (res.statusCode == 200) {
        final data = responseRandomLottoFromJson(res.body);
        if (!mounted) return;
        setState(() => selectedResult = data);
      } else if (res.statusCode == 404) {
        if (!mounted) return;
        setState(() => selectedResult = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ไม่พบผลรางวัลของงวด ${picked.drawNumber} (${picked.date})',
            ),
          ),
        );
      } else {
        log('bydate failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetch by selected exception: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showing = selectedResult;
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

    final resultKey = ValueKey(_selectedDrawValue ?? 'none');

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedDrawValue != null) {
            await _fetchBySelectedDraw(_selectedDrawValue!);
          }
          await _fetchDrawList();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== Header =====
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 200),
                  color: brand,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Image.asset("assets/images/smalllogo.png",
                            fit: BoxFit.cover, height: 40),
                        const SizedBox(width: 8),
                        const Text(
                          "Lotto 888",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu,
                              size: 42, color: Colors.white),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      )
                    ],
                  ),
                ),

                // ===== Card ตรวจสลาก =====
                Transform.translate(
                  offset: const Offset(0, -180),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                      color: const Color(0xFFD3EAFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

                            // Dropdown งวด
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _drawItems
                                      .any((e) => e.value == _selectedDrawValue)
                                  ? _selectedDrawValue
                                  : null,
                              items: _drawItems,
                              decoration: InputDecoration(
                                labelText: "งวดวันที่",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 115, 122, 128),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (v) async {
                                setState(() {
                                  _selectedDrawValue = v;
                                  selectedResult = null; // เคลียร์ผลเก่า
                                });
                                if (v != null) {
                                  await _fetchBySelectedDraw(v);
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
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
                                      fontSize: 20,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 115, 122, 128),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 16),

                            if (loading)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: LinearProgressIndicator(minHeight: 3),
                              ),

                            ElevatedButton(
                              onPressed: _checkLotto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brand,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: const Text(
                                "ตรวจสลากกินแบ่ง",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ===== แบนเนอร์ภาพ (ของเดิม) =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Transform.translate(
                    offset: const Offset(0, -170),
                    child: Image.asset(
                      'assets/images/cardhome.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // ===== ส่วนแสดงผลรางวัล =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    key: resultKey,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _title(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: brand,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedDrawValue != null && selectedResult == null)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (selectedResult != null) ...[
                        // รางวัลที่ 1
                        _PrizeCard(
                          title: 'รางวัลที่ 1',
                          number: first,
                          amountText: 'รางวัลละ: $prize1Amount บาท',
                        ),
                        const SizedBox(height: 12),

                        // เลขท้าย 3 & 2 ตัว
                        Row(
                          children: [
                            Expanded(
                              child: _MiniPrizeCard(
                                title: 'เลขท้าย 3 ตัว',
                                number: last3,
                                amountText: 'รางวัลละ: $last3Amount บาท',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniPrizeCard(
                                title: 'เลขท้าย 2 ตัว',
                                number: last2,
                                amountText: 'รางวัลละ: $last2Amount บาท',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // รางวัลที่ 2
                        _PrizeCard(
                          title: 'รางวัลที่ 2',
                          number: second,
                          amountText: 'รางวัลละ: $prize2Amount บาท',
                        ),
                        const SizedBox(height: 18),

                        // รางวัลที่ 3
                        _PrizeCard(
                          title: 'รางวัลที่ 3',
                          number: third,
                          amountText: 'รางวัลละ: $prize3Amount บาท',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Widgets ย่อย ====================

class _PrizeCard extends StatelessWidget {
  final String title;
  final String number;
  final String amountText;
  const _PrizeCard({
    Key? key,
    required this.title,
    required this.number,
    required this.amountText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF007BFF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
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
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
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
                    number,
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: brand),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amountText,
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
    );
  }
}

class _MiniPrizeCard extends StatelessWidget {
  final String title;
  final String number;
  final String amountText;
  const _MiniPrizeCard({
    Key? key,
    required this.title,
    required this.number,
    required this.amountText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF007BFF);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
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
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
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
                    number,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: brand),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'รางวัลละ: ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                      Text(
                        amountText.replaceAll('รางวัลละ: ', ''),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
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
    );
  }
}
