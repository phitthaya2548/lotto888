import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // << ต้องมี
import 'package:lotto/config/config.dart';
import 'package:lotto/models/response/res_lotto.dart';
import 'package:lotto/pages/admin/widgets/app_headeradmin.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  static const brand = Color(0xFF007BFF);

  String url = '';
  bool loading = false;
  ResponseRandomLotto? latest;

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((c) async {
      final raw = (c['apiEndpoint'] ?? '').toString();
      final normalized = raw.trim().replaceAll(RegExp(r'/+$'), '');
      if (!mounted) return;
      setState(() => url = normalized);
      await _fetchLatest();
    });
  }

  Future<void> _fetchLatest() async {
    if (url.isEmpty) return;
    setState(() => loading = true);
    try {
      var res = await http.get(Uri.parse('$url/draws'));
      if (res.statusCode == 200) {
        final data = responseRandomLottoFromJson(res.body);
        if (!mounted) return;
        setState(() => latest = data);
      } else {
        log('fetch latest failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetch latest exception: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = latest?.draw.results;
    final a = latest?.draw.amounts;

    final first = r?.first ?? '-';
    final second = r?.second ?? '-';
    final third = r?.third ?? '-';
    final last3 = r?.last3 ?? '-';
    final last2 = r?.last2 ?? '-';

    final prize1Amount = _fmt(a?.prize1Amount ?? 0);
    final prize2Amount = _fmt(a?.prize2Amount ?? 0);
    final prize3Amount = _fmt(a?.prize3Amount ?? 0);
    final last3Amount = _fmt(a?.last3Amount ?? 0);
    final last2Amount = _fmt(a?.last2Amount ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppHeaderAdmin(),
      body: RefreshIndicator(
        onRefresh: _fetchLatest,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
        
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Image.asset("assets/images/person.png", width: 32, height: 32, fit: BoxFit.contain),
                            const SizedBox(height: 6),
                            const Text('ขายแล้ว', textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('50 ใบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Image.asset("assets/images/tiket.png", width: 32, height: 32, fit: BoxFit.contain),
                            const SizedBox(height: 6),
                            const Text('ขายลอตโต้แล้ว', textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('50 ใบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Image.asset("assets/images/bag.png", width: 32, height: 32, fit: BoxFit.contain),
                            const SizedBox(height: 6),
                            const Text('ยอดขายรวม', textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('5,000 บาท', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 16),
        
              const Text('ผลรางวัลล่าสุด',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brand)),
              const SizedBox(height: 8),
        
              // รางวัลที่ 1
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text('รางวัลที่ 1',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(first,
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: brand)),
                            const SizedBox(height: 6),
                            Text('รางวัลละ: $prize1Amount บาท',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 18),
        
              // เลขท้าย 3 & 2 ตัว
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: brand,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Center(
                                child: Text('เลขท้าย 3 ตัว',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(last3,
                                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: brand)),
                                  const SizedBox(height: 4),
                                  Text('รางวัลละ: $last3Amount บาท',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: brand,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Center(
                                child: Text('เลขท้าย 2 ตัว',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(last2,
                                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: brand)),
                                  const SizedBox(height: 4),
                                  Text('รางวัลละ: $last2Amount บาท',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
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
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text('รางวัลที่ 2',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(second,
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: brand)),
                            const SizedBox(height: 6),
                            Text('รางวัลละ: $prize2Amount บาท',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
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
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text('รางวัลที่ 3',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(third,
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: brand)),
                            const SizedBox(height: 6),
                            Text('รางวัลละ: $prize3Amount บาท',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
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
