import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // ผลรางวัลล่าสุด
  ResponseRandomLotto? latest;

  // Dashboard stats
  int usersCount = 0;      // ผู้ใช้ทั้งหมด
  int soldCount = 0;       // ขายแล้ว
  int income = 0;          // ยอดขายรวม (บาท)

  String _fmt(num n) => n
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((c) async {
      final raw = (c['apiEndpoint'] ?? '').toString();
      final normalized = raw.trim().replaceAll(RegExp(r'/+$'), '');
      if (!mounted) return;
      setState(() => url = normalized);
      await _loadAll();
    });
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _fetchLatest(),
      _fetchDashboardStats(),
    ]);
  }

  // ===== API: ผลล่าสุด =====
  Future<void> _fetchLatest() async {
    if (url.isEmpty) return;
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('$url/draws'));
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

  // ===== API: การ์ดสรุป (ไม่ต้อง map/ไม่ต้อง cast as Map) =====
  Future<void> _fetchDashboardStats() async {
    if (url.isEmpty) return;
    try {
      // 1) ผู้ใช้ทั้งหมด
      final usersRes = await http.get(Uri.parse('$url/dataadmin/users'));
      if (usersRes.statusCode == 200) {
        final m = jsonDecode(usersRes.body);
        usersCount = (m['users'] is int)
            ? m['users']
            : int.tryParse('${m['users']}') ?? 0;
      } else {
        log('users failed: ${usersRes.statusCode} ${usersRes.body}');
      }

      // 2) ขายแล้ว
      final selledRes = await http.get(Uri.parse('$url/dataadmin/selled'));
      if (selledRes.statusCode == 200) {
        final m = jsonDecode(selledRes.body);
soldCount = (m['soldTickets'] is int)
    ? m['soldTickets']
    : int.tryParse('${m['soldTickets']}') ?? 0;

      } else {
        log('selled failed: ${selledRes.statusCode} ${selledRes.body}');
      }

      // 3) ยอดขายรวม
      final incomeRes = await http.get(Uri.parse('$url/dataadmin/income'));
      if (incomeRes.statusCode == 200) {
        final m = jsonDecode(incomeRes.body);
        income = (m['income'] is int)
            ? m['income']
            : int.tryParse('${m['income']}') ?? 0;
      } else {
        log('income failed: ${incomeRes.statusCode} ${incomeRes.body}');
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      log('dashboard stats exception: $e');
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
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),

              // ===== การ์ดสรุป 3 ช่อง =====
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      iconPath: "assets/images/person.png",
                      title: "ผู้ใช้ทั้งหมด",
                      value: "${_fmt(usersCount)} คน",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      iconPath: "assets/images/tiket.png",
                      title: "ขายลอตโต้แล้ว",
                      value: "${_fmt(soldCount)} ใบ",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      iconPath: "assets/images/bag.png",
                      title: "ยอดขายรวม",
                      value: "${_fmt(income)} บาท",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'ผลรางวัลล่าสุด',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brand),
              ),
              const SizedBox(height: 8),

              // รางวัลที่ 1
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: _PrizeBigCard(
                  title: 'รางวัลที่ 1',
                  number: first,
                  amountText: 'รางวัลละ: $prize1Amount บาท',
                ),
              ),

              const SizedBox(height: 18),

              // เลขท้าย 3 & 2 ตัว
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _PrizeSmallCard(
                        title: 'เลขท้าย 3 ตัว',
                        number: last3,
                        amountText: 'รางวัลละ: $last3Amount บาท',
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _PrizeSmallCard(
                        title: 'เลขท้าย 2 ตัว',
                        number: last2,
                        amountText: 'รางวัลละ: $last2Amount บาท',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // รางวัลที่ 2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: _PrizeBigCard(
                  title: 'รางวัลที่ 2',
                  number: second,
                  amountText: 'รางวัลละ: $prize2Amount บาท',
                ),
              ),

              const SizedBox(height: 18),

              // รางวัลที่ 3
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: _PrizeBigCard(
                  title: 'รางวัลที่ 3',
                  number: third,
                  amountText: 'รางวัลละ: $prize3Amount บาท',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== Widgets ย่อย ======================

class _StatCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String value;
  const _StatCard({
    required this.iconPath,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Image.asset(iconPath, width: 32, height: 32, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrizeBigCard extends StatelessWidget {
  final String title;
  final String number;
  final String amountText;
  const _PrizeBigCard({
    required this.title,
    required this.number,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF007BFF);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2)),
        ],
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
              child: Text(
                'รางวัลที่ 1',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  number,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: brand),
                ),
                const SizedBox(height: 6),
                Text(
                  amountText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeSmallCard extends StatelessWidget {
  final String title;
  final String number;
  final String amountText;
  const _PrizeSmallCard({
    required this.title,
    required this.number,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF007BFF);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
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
            child: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  number,
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: brand),
                ),
                const SizedBox(height: 4),
                Text(
                  amountText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
