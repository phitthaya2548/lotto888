import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:lotto/config/config.dart';
import 'package:lotto/models/response/les_lish_balanc.dart';
import 'package:lotto/models/response/res_balance.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/widgets/app_header.dart';
import '../../widgets/app_drawer.dart';

class WalletLotto extends StatefulWidget {
  const WalletLotto({super.key});

  @override
  State<WalletLotto> createState() => _WalletLottoState();
}

class _WalletLottoState extends State<WalletLotto> {
  String url = '';
  int _balance = 0;
  bool _loading = true;

  final _money = NumberFormat('#,##0', 'th_TH');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final config = await Configuration.getConfig();
      url = (config['apiEndpoint'] ?? '').toString();
      await showBalance();
      await showLishBalance();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดค่าตั้งต้นไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> showLishBalance() async {
    if (url.isEmpty) return;
    try {
      final userId = await AuthService.getId();
      final uri = Uri.parse('$url/wallets/transactions')
          .replace(queryParameters: {'userId': userId.toString()});

      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = responseRandomListBalanceFromJson(resp.body);
        log('balance: ${data.toJson()}');
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('โหลดยอดเงินไม่สำเร็จ (${resp.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> showBalance() async {
    if (url.isEmpty) return;
    try {
      final userId = await AuthService.getId();
      final uri = Uri.parse('$url/wallets/balance')
          .replace(queryParameters: {'userId': userId.toString()});

      final resp = await http.get(uri).timeout(const Duration(seconds: 12));

      if (resp.statusCode == 200) {
        final data = responseRandomBalanceFromJson(resp.body);
        log('balance: ${data.toJson()}');
        if (!mounted) return;
        setState(() {
          _balance = data.wallet.balance;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('โหลดยอดเงินไม่สำเร็จ (${resp.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _onRefresh() async {
    await showBalance();
  }

  @override
  Widget build(BuildContext context) {
    const brandGradient = LinearGradient(
      colors: [Color(0xFF0593FF), Color(0xFF4DBBFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppHeader(),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: brandGradient,
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
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ยอดเงินคงเหลือ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _loading
                            ? Container(
                                width: 120,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                            : Text(
                                "${_money.format(_balance)} บาท",
                                style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  "รายการ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // TODO: แทนที่ด้วยรายการจริงจาก API เมื่อพร้อม
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
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _TxLeft(
                        title: "สถานะ: ถูกรางวัล",
                        subtitle: "รหัสการเดิมพัน ABC123"),
                    _TxRight(
                        amountText: "1,000,000 บาท",
                        icon: Icons.check_circle,
                        color: Colors.green),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _TxLeft extends StatelessWidget {
  const _TxLeft({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _TxRight extends StatelessWidget {
  const _TxRight(
      {required this.amountText, required this.icon, required this.color});
  final String amountText;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          amountText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
