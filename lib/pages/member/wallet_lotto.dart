import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:lotto/config/config.dart';
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

  // ตัวช่วยฟอร์แมต (เดือนภาษาอังกฤษ)
  final _money = NumberFormat('#,##0', 'en_US');
  final _dateFmt = DateFormat('d MMM yyyy, HH:mm', 'en_US');

  // รายการธุรกรรมจาก API
  List<Map<String, dynamic>> _txs = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final config = await Configuration.getConfig();
      url = (config['apiEndpoint'] ?? '').toString().replaceAll(RegExp(r'/+$'), '');
      await showBalance();
      await showTransactions();
    } catch (e) {
     
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> showTransactions() async {
    if (url.isEmpty) return;
    try {
      final userId = await AuthService.getId();
      final uri = Uri.parse('$url/wallets/transactions')
          .replace(queryParameters: {'userId': userId.toString(), 'limit': '100'});

      final sw = Stopwatch()..start();
      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      log('GET /wallets/transactions took ${sw.elapsedMilliseconds} ms');

      if (resp.statusCode == 200) {
        final obj = jsonDecode(resp.body) as Map<String, dynamic>;
        final items = (obj['items'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (!mounted) return;
        setState(() {
          _txs = items;
        });
      } else {
       
      }
    } catch (e) {
     
    }
  }

  Future<void> showBalance() async {
    if (url.isEmpty) return;
    try {
      final userId = await AuthService.getId();
      final uri = Uri.parse('$url/wallets/balance')
          .replace(queryParameters: {'userId': userId.toString()});

      final sw = Stopwatch()..start();
      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      log('GET /wallets/balance took ${sw.elapsedMilliseconds} ms');

      if (resp.statusCode == 200) {
        final data = responseRandomBalanceFromJson(resp.body);
        if (!mounted) return;
        setState(() {
          _balance = data.wallet.balance;
        });
      } else {
      }
    } catch (e) {
      
    }
  }

  Future<void> _onRefresh() async {
    await showBalance();
    await showTransactions();
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
            // ยอดคงเหลือ
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
                          "Available Balance",
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
                                "${_money.format(_balance)} THB",
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

            // หัวข้อ
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  "Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // รายการธุรกรรมจริง
            SliverList.builder(
              itemCount: _txs.length,
              itemBuilder: (_, i) {
                final t = _txs[i];

                // amount เป็นสตริงในตัวอย่าง ("-100.00")
                final amountStr = (t['amount'] ?? '0').toString().replaceAll(',', '');
                final amount = double.tryParse(amountStr) ?? 0.0;
                final isIn = amount > 0;

                final txType = (t['tx_type'] ?? '').toString(); // PURCHASE/DEPOSIT/PRIZE...
                final note = (t['note'] ?? '').toString();
                final refType = (t['ref_type'] ?? '').toString();
                final refId = (t['ref_id'] ?? '').toString();

                // วันที่เป็น ISO string -> ฟอร์แมตเดือนอังกฤษ
                final createdAtStr = () {
                  final raw = t['created_at']?.toString();
                  if (raw == null || raw.isEmpty) return '';
                  try {
                    final dt = DateTime.parse(raw).toLocal();
                    return _dateFmt.format(dt);
                  } catch (_) {
                    return raw;
                  }
                }();

                final title = txType.isEmpty ? 'Transaction' : txType;
                final subtitle = note.isNotEmpty
                    ? note
                    : [refType, refId].where((e) => e.isNotEmpty).join(' ');

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    children: [
                      // ซ้าย
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (subtitle.isNotEmpty)
                              Text(subtitle, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(createdAtStr,
                                style: const TextStyle(color: Colors.black38, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ขวา
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            isIn ? Icons.call_received : Icons.call_made,
                            color: isIn ? Colors.green : Colors.red,
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (isIn ? '+' : '-') + _money.format(amount.abs()) + ' THB',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}
