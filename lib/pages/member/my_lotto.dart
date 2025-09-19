import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/config/config.dart';
import 'package:lotto/models/response/res_lesson.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/widgets/app_drawer.dart';

class MyTicket extends StatefulWidget {
  const MyTicket({Key? key}) : super(key: key);

  @override
  State<MyTicket> createState() => _MyTicketState();
}

class _MyTicketState extends State<MyTicket> {
  static const brand = Color(0xFF007BFF);

  String url = '';
  String? _username;
  String? _userId; 
  int? _userIdInt; 

  String? _selectedDraw; 
  List<DropdownMenuItem<String>> _drawItems = const [];
  List<Draw> _draws = [];


  final List<Map<String, dynamic>> tickets = [];

  bool _loadingDraws = false;
  bool _loadingTickets = false;


  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _drawValue(Draw d) => '${_dateStr(d.drawDate)}#${d.drawNumber}';

  String _formatTicketNumber(String n) {
    final digits = n.replaceAll(RegExp(r'\D'), '');
    return digits.split('').join(' ');
  }

  String _thaiMonth(int m) {
    const th = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return th[m];
  }

  String _thaiDate(DateTime d) {
    final y = d.year + 543;
    return '${d.day} ${_thaiMonth(d.month)} $y';
  }

  ({DateTime drawDate, int drawNumber}) _parseSelectedDraw(String value) {
    final parts = value.split('#');
    if (parts.length != 2) {
      throw FormatException('Invalid selected draw value: $value');
    }
    final dateStr = parts[0];
    final drawNo = int.parse(parts[1]);
    final d = DateTime.parse(dateStr);
    return (drawDate: d, drawNumber: drawNo);
  }

  String _prizeLabel(String? code) {
    switch (code) {
      case 'PRIZE1':
        return 'รางวัลที่ 1';
      case 'PRIZE2':
        return 'รางวัลที่ 2';
      case 'PRIZE3':
        return 'รางวัลที่ 3';
      case 'LAST3':
        return 'รางวัลเลขท้าย 3 ตัว';
      case 'LAST2':
        return 'รางวัลเลขท้าย 2 ตัว';
      default:
        return '';
    }
  }

  String _formatBaht(double amt) {
    final s = amt.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final idxFromRight = intPart.length - i;
      buf.write(intPart[i]);
      if (idxFromRight > 1 && idxFromRight % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}.$decPart บาท';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      if (mounted && _selectedDraw != null) {
        await _fetchBuyerTicketsForSelectedDraw();
      }
    });

    _loadUser();
  }

  Future<void> _loadUser() async {
    final session = await AuthService.getId();
    final session2 = await AuthService.getUsername();
    if (!mounted) return;
    setState(() {
      _userId = session;
      _username = session2;
      _userIdInt = int.tryParse(session ?? '');
    });
    if (_selectedDraw?.isNotEmpty == true && _userIdInt != null) {
      await _fetchBuyerTicketsForSelectedDraw();
    }
  }


  Future<void> _fetchDrawList() async {
    if (url.isEmpty) return;
    setState(() => _loadingDraws = true);
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

        if (!mounted) return;
        setState(() {
          _draws = data.draws;
          _drawItems = items;
          _selectedDraw = items.isNotEmpty ? items.first.value : null;
        });

        for (final d in data.draws) {
          log("draw list -> รอบ ${d.drawNumber}, วันที่ ${_dateStr(d.drawDate)}");
        }
      } else {
        log('fetchDrawList failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('fetchDrawList error: $e');
    } finally {
      if (mounted) setState(() => _loadingDraws = false);
    }
  }


  Future<void> _fetchBuyerTicketsForSelectedDraw() async {
    if (url.isEmpty) return;
    if (_userIdInt == null) return;
    if (_selectedDraw == null || _selectedDraw!.isEmpty) return;

    setState(() => _loadingTickets = true);
    try {
      final parsed = _parseSelectedDraw(_selectedDraw!);
      final drawDate = parsed.drawDate;
      final drawNumber = parsed.drawNumber;


      final uriList = Uri.parse('$url/tickets/by-buyer-and-draw').replace(
        queryParameters: {
          'buyer_user_id': _userIdInt!.toString(),
          'draw_number': drawNumber.toString(),
        },
      );

      final resList = await http.get(uriList);
      if (resList.statusCode != 200) {
        log('fetchBuyerTickets failed: ${resList.statusCode} ${resList.body}');
        return;
      }

      final Map<String, dynamic> bodyList = jsonDecode(resList.body);
      if (bodyList['success'] != true) {
        log('fetchBuyerTickets not success: $bodyList');
        return;
      }

      final List<dynamic> list = (bodyList['tickets'] as List<dynamic>? ?? []);
      final dateText = _thaiDate(drawDate);

      final newTickets = list.map<Map<String, dynamic>>((e) {
        final raw = (e['ticket_number'] ?? '').toString();
        final statusDb = (e['status'] ?? '').toString();
        final claimed = statusDb == 'REDEEMED';
        return {
          'number': _formatTicketNumber(raw),
          'raw': raw,
          'date': dateText,
          'draw': drawNumber,
          'claimed': claimed,
          'status': claimed ? 'CLAIMED' : 'PENDING',
          'statusLabel': claimed ? 'รับเงินแล้ว' : 'ยังไม่ประกาศ',
          'prizeCode': null,
          'prizeAmount': 0.0,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        tickets
          ..clear()
          ..addAll(newTickets);
      });

      await _checkPrizesForSelectedDraw(drawNumber);
    } catch (e) {
      log('fetchBuyerTickets error: $e');
    } finally {
      if (mounted) setState(() => _loadingTickets = false);
    }
  }

  Future<void> _checkPrizesForSelectedDraw(int drawNumber) async {
    if (url.isEmpty) return;
    if (_userIdInt == null) return;

    final uri = Uri.parse('$url/draws/prize-check').replace(
      queryParameters: {
        'buyer_user_id': _userIdInt!.toString(),
        'draw_number': drawNumber.toString(),
      },
    );

    try {
      final res = await http.get(uri);

      if (res.statusCode == 409) {
        log('prize-check: งวดยังไม่ปิดประกาศผล');
        return;
      }
      if (res.statusCode != 200) {
        log('prize-check failed: ${res.statusCode} ${res.body}');
        return;
      }

      final Map<String, dynamic> body = jsonDecode(res.body);
      if (body['success'] != true) {
        log('prize-check not success: $body');
        return;
      }

      final List<dynamic> results = (body['results'] as List<dynamic>? ?? []);
      final Map<String, dynamic> hitByRaw = {
        for (final r in results) (r['ticketNumber'] ?? '').toString(): r,
      };

      if (!mounted) return;
      setState(() {
        for (var i = 0; i < tickets.length; i++) {
          if (tickets[i]['claimed'] == true) {
            tickets[i]['status'] = 'CLAIMED';
            tickets[i]['statusLabel'] = 'รับเงินแล้ว';
            continue;
          }
          final raw = (tickets[i]['raw'] ?? '').toString();
          final r = hitByRaw[raw];

          if (r == null) {
            tickets[i]['status'] = 'PENDING';
            tickets[i]['statusLabel'] = 'ยังไม่ประกาศ';
            tickets[i]['prizeCode'] = null;
            tickets[i]['prizeAmount'] = 0.0;
            continue;
          }

          final amountNum = (r['awardedAmount'] ?? 0);
          final amount = amountNum is num
              ? amountNum.toDouble()
              : double.tryParse(amountNum.toString()) ?? 0.0;
          final best = (r['bestPrize'] ?? '') as String?;

          if (amount > 0 && best != null && best.isNotEmpty) {
            tickets[i]['status'] = 'WIN';
            tickets[i]['statusLabel'] = 'ถูก${_prizeLabel(best)}';

            tickets[i]['prizeCode'] = best;
            tickets[i]['prizeAmount'] = amount;
          } else {
            tickets[i]['status'] = 'LOSE';
            tickets[i]['statusLabel'] = 'ไม่ถูกรางวัล';
            tickets[i]['prizeCode'] = null;
            tickets[i]['prizeAmount'] = 0.0;
          }
        }
      });
    } catch (e) {
      log('prize-check error: $e');
    }
  }

  Future<void> _claimTicket(int index) async {
    final t = tickets[index];
    final isWinner = t['status'] == 'WIN';
    final isClaimed = t['claimed'] == true;
    if (!isWinner || isClaimed) return;
    if (_userIdInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบรหัสผู้ใช้ (user id)')),
      );
      return;
    }

    try {
      final uri = Uri.parse('$url/draws/claim');
      final payload = {
        'buyerUserId': _userIdInt,
        'buyer_user_id': _userIdInt,
        'drawNumber': t['draw'],
        'draw_number': t['draw'],
        'ticketNumber': t['raw'],
        'ticket_number': t['raw'],
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final prizeCode = body['prize']?.toString();
        final amountAny = body['awardedAmount'];
        final amount = amountAny is num
            ? amountAny.toDouble()
            : double.tryParse(amountAny?.toString() ?? '0') ?? 0.0;
        final prizeLabel = _prizeLabel(prizeCode);
        final amountText = _formatBaht(amount);

        setState(() {
          tickets[index]['claimed'] = true;
          tickets[index]['status'] = 'CLAIMED';
          tickets[index]['statusLabel'] = 'รับเงินแล้ว';
        });
        showBuyDialog(
          username: _username, 
          prizeLabel: prizeLabel.isEmpty ? 'รางวัล' : prizeLabel,
          amountText: amountText,
          autoClose: const Duration(seconds: 8),
        );
        return;
      }


      String msg;
      try {
        final m = jsonDecode(res.body);
        msg = m['message']?.toString() ?? res.body;

       
        final code = (m['code'] ?? '').toString();
        if (res.statusCode == 409 &&
            (code == 'ALREADY_REDEEMED' || code == 'DUPLICATE_PRIZE_TX')) {
          setState(() {
            tickets[index]['claimed'] = true;
            tickets[index]['status'] = 'CLAIMED';
            tickets[index]['statusLabel'] = 'รับเงินแล้ว';
          });
        }
      } catch (_) {
        msg = res.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รับเงินไม่สำเร็จ (${res.statusCode}): $msg')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: brand,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
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
                value: _drawItems.any((e) => e.value == _selectedDraw)
                    ? _selectedDraw
                    : null,
                items: _drawItems,
                decoration: InputDecoration(
                  labelText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 115, 122, 128),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (v) async {
                  setState(() => _selectedDraw = v);
                  await _fetchBuyerTicketsForSelectedDraw();
                },
              ),
            ),
            if (_loadingDraws || _loadingTickets) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 4),
            Expanded(
              child: tickets.isEmpty
                  ? const Center(
                      child: Text(
                        'ยังไม่มีสลากในงวดนี้',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: tickets.length,
                      itemBuilder: (_, i) {
                        final t = tickets[i];
                        final isWinner = t['status'] == 'WIN';
                        final isClaimed = t['status'] == 'CLAIMED';

                        
                        final Color btnColor = isClaimed
                            ? const Color(0xFFA5E8B1) 
                            : (isWinner
                                ? const Color(0xFF34C759)
                                : Colors.grey);

                        final bool btnEnabled = isWinner && !isClaimed;
                        final String btnText =
                            isClaimed ? 'รับเงินแล้ว' : 'ขึ้นเงิน';

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              t['number'] ?? '',
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
                                                'งวดที่ ${t['draw'] ?? '—'}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black
                                                      .withOpacity(.6),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                t['date'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black
                                                      .withOpacity(.6),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(18, 0, 0, 0),
                                    child: Text(
                                      (t['statusLabel'] ?? 'ยังไม่ประกาศ')
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: btnEnabled
                                        ? () => _claimTicket(i)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: btnColor,
                                      disabledBackgroundColor: isClaimed
                                          ? const Color(0xFFA5E8B1)
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 48,
                                        vertical: 5,
                                      ),
                                    ),
                                    child: Text(
                                      btnText,
                                      style: const TextStyle(
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
}

void showBuyDialog({
  String? username,
  required String prizeLabel,
  required String amountText,
  Duration autoClose = const Duration(seconds: 10),
}) {
  Get.dialog(
    Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        Center(
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ยินดีด้วย คุณถูกรางวัล $prizeLabel",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ชื่อ ${username ?? '-'} คุณเป็นเศรษฐีแล้ว",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "เป็นเงินรางวัล $amountText",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
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
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
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
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
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
    barrierDismissible: false,
    barrierColor: Colors.transparent,
  );

  Future.delayed(autoClose, () {
    if (Get.isDialogOpen ?? false) Get.back();
  });
}
