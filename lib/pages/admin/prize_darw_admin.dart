import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/config/config.dart';
import 'package:lotto/models/request/req_lotto.dart';
import 'package:lotto/models/response/res_lotto.dart';
import 'package:lotto/pages/admin/widgets/app_headeradmin.dart';

class PrizeDarwAdmin extends StatefulWidget {
  const PrizeDarwAdmin({super.key});

  @override
  State<PrizeDarwAdmin> createState() => _PrizeDarwAdminState();
}

class _PrizeDarwAdminState extends State<PrizeDarwAdmin> {
  int _mode = 0;

  bool _isEditingLast3 = false;
  bool _isEditingLast2 = false;
  bool _isprize1 = false;
  bool _isprize2 = false;
  bool _isprize3 = false;

  String url = '';
  String? rFirst;
  String? rSecond;
  String? rThird;
  String? rLast3;
  String? rLast2;

  String? prize1Amount;
  String? prize2Amount;
  String? prize3Amount;
  String? last3Amount;
  String? last2Amount;
  final TextEditingController _prize1 = TextEditingController();
  final TextEditingController _prize2 = TextEditingController();
  final TextEditingController _prize3 = TextEditingController();
  final TextEditingController _last3 = TextEditingController();
  final TextEditingController _last2 = TextEditingController();
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) async {
      final raw = (config['apiEndpoint'] ?? '').toString().trim();
      final normalized = raw.replaceAll(RegExp(r'/+$'), '');

      if (!mounted) return;
      setState(() => url = normalized);

      await _fetchLatest();
    });
  }

  Future<void> _fetchLatest() async {
    if (url.isEmpty) return;
    try {
      setState(() => _loading = true);
      final uri = Uri.parse('$url/draws');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final datares = responseRandomLottoFromJson(res.body);
        setState(() {
          rFirst = datares.draw.results.first;
          rSecond = datares.draw.results.second;
          rThird = datares.draw.results.third;
          rLast3 = datares.draw.results.last3;
          rLast2 = datares.draw.results.last2;
          prize1Amount = datares.draw.amounts.prize1Amount.toString();
          prize2Amount = datares.draw.amounts.prize2Amount.toString();
          prize3Amount = datares.draw.amounts.prize3Amount.toString();
          last3Amount = datares.draw.amounts.last3Amount.toString();
          last2Amount = datares.draw.amounts.last2Amount.toString();
          _prize1.text = datares.draw.amounts.prize1Amount.toString();
          _prize2.text = datares.draw.amounts.prize2Amount.toString();
          _prize3.text = datares.draw.amounts.prize3Amount.toString();
          _last3.text = datares.draw.amounts.last3Amount.toString();
          _last2.text = datares.draw.amounts.last2Amount.toString();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('โหลดผลล่าสุดไม่สำเร็จ')),
          );
        }
      }
    } catch (e) {
      debugPrint('fetchLatest exception: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _prize1.dispose();
    _prize2.dispose();
    _prize3.dispose();
    _last3.dispose();
    _last2.dispose();
    super.dispose();
  }

  Future<void> randomlotto() async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API endpoint ยังไม่พร้อม')),
      );
      return;
    }

    final String mode = _mode == 0 ? "ALL" : "SOLD_ONLY";

    try {
      final req = RequestRandomLotto(
        prize1Amount: int.tryParse(_prize1.text) ?? 0,
        prize2Amount: int.tryParse(_prize2.text) ?? 0,
        prize3Amount: int.tryParse(_prize3.text) ?? 0,
        last3Amount: int.tryParse(_last3.text) ?? 0,
        last2Amount: int.tryParse(_last2.text) ?? 0,
        uniqueExact: true,
        sourceMode: mode,
      );

      final res = await http.post(
        Uri.parse('$url/draws/randomlotto'),
        headers: {"Content-Type": "application/json"},
        body: requestRandomLottoToJson(req),
      );
      log(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final datares = responseRandomLottoFromJson(res.body);

        setState(() {
          rFirst = datares.draw.results.first;
          rSecond = datares.draw.results.second;
          rThird = datares.draw.results.third;
          rLast3 = datares.draw.results.last3;
          rLast2 = datares.draw.results.last2;
          prize1Amount = datares.draw.amounts.prize1Amount.toString();
          prize2Amount = datares.draw.amounts.prize2Amount.toString();
          prize3Amount = datares.draw.amounts.prize3Amount.toString();
          last3Amount = datares.draw.amounts.last3Amount.toString();
          last2Amount = datares.draw.amounts.last2Amount.toString();
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('สำเร็จ: ออกรางวัลสำเร็จ')));
        log("API Response: ${res.body}");
      }
    } catch (e) {
      log("randomlotto error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF007BFF);

    return Scaffold(
      appBar: AppHeaderAdmin(),
      backgroundColor: const Color(0xFFEAF2FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ออกรางวัล",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: brand),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    value: 0,
                    groupValue: _mode,
                    title: const Text("สุ่มลอตเตอรี่ทั้งหมด"),
                    activeColor: brand,
                    onChanged: (v) => setState(() => _mode = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    value: 1,
                    groupValue: _mode,
                    title: const Text("สุ่มลอตเตอรี่ที่ขายแล้ว"),
                    activeColor: brand,
                    onChanged: (v) => setState(() => _mode = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ------ การตั้งค่าเงินรางวัล ------
            Card(
              color: const Color(0xFFEAF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blue, width: 2),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("เงินรางวัลงวดนี้",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(""),
                      ],
                    ),
                    Column(
                      children: [
                        // Prize 1
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: const [
                                Icon(Icons.confirmation_number,
                                    color: Colors.black54, size: 20),
                                SizedBox(width: 6),
                                Text("รางวัลที่1",
                                    style: TextStyle(fontSize: 16)),
                              ]),
                              Row(
                                children: [
                                  _isprize1
                                      ? SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _prize1,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onSubmitted: (_) => setState(
                                                () => _isprize1 = false),
                                          ),
                                        )
                                      : Text(
                                          _prize1.text,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _isprize1 = !_isprize1),
                                    icon: Icon(
                                        _isprize1 ? Icons.check : Icons.edit,
                                        size: 18),
                                    color: Colors.black54,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Prize 2
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: const [
                                Icon(Icons.confirmation_number,
                                    color: Colors.black54, size: 20),
                                SizedBox(width: 6),
                                Text("รางวัลที่2",
                                    style: TextStyle(fontSize: 16)),
                              ]),
                              Row(
                                children: [
                                  _isprize2
                                      ? SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _prize2,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onSubmitted: (_) => setState(
                                                () => _isprize2 = false),
                                          ),
                                        )
                                      : Text(
                                          _prize2.text,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _isprize2 = !_isprize2),
                                    icon: Icon(
                                        _isprize2 ? Icons.check : Icons.edit,
                                        size: 18),
                                    color: Colors.black54,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Prize 3
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: const [
                                Icon(Icons.confirmation_number,
                                    color: Colors.black54, size: 20),
                                SizedBox(width: 6),
                                Text("รางวัลที่3",
                                    style: TextStyle(fontSize: 16)),
                              ]),
                              Row(
                                children: [
                                  _isprize3
                                      ? SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _prize3,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onSubmitted: (_) => setState(() =>
                                                _isprize3 = false), // แก้จุดผิด
                                          ),
                                        )
                                      : Text(
                                          _prize3.text,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _isprize3 = !_isprize3),
                                    icon: Icon(
                                        _isprize3 ? Icons.check : Icons.edit,
                                        size: 18),
                                    color: Colors.black54,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Last 3
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: const [
                                Icon(Icons.confirmation_number,
                                    color: Colors.black54, size: 20),
                                SizedBox(width: 6),
                                Text("รางวัลเลขท้าย 3 ตัว",
                                    style: TextStyle(fontSize: 16)),
                              ]),
                              Row(
                                children: [
                                  _isEditingLast3
                                      ? SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _last3,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onSubmitted: (_) => setState(
                                                () => _isEditingLast3 = false),
                                          ),
                                        )
                                      : Text(
                                          _last3.text,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () => setState(() =>
                                        _isEditingLast3 = !_isEditingLast3),
                                    icon: Icon(
                                        _isEditingLast3
                                            ? Icons.check
                                            : Icons.edit,
                                        size: 18),
                                    color: Colors.black54,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Last 2
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: const [
                                Icon(Icons.confirmation_number,
                                    color: Colors.black54, size: 20),
                                SizedBox(width: 6),
                                Text("รางวัลเลขท้าย 2 ตัว",
                                    style: TextStyle(fontSize: 16)),
                              ]),
                              Row(
                                children: [
                                  _isEditingLast2
                                      ? SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _last2,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onSubmitted: (_) => setState(() =>
                                                _isEditingLast2 =
                                                    false), // แก้จุดผิด
                                          ),
                                        )
                                      : Text(
                                          _last2.text,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () => setState(() =>
                                        _isEditingLast2 = !_isEditingLast2),
                                    icon: Icon(
                                        _isEditingLast2
                                            ? Icons.check
                                            : Icons.edit,
                                        size: 18),
                                    color: Colors.black54,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 82, 255, 87),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: randomlotto,
                        child: const Text(
                          "สุ่มรางวัล",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ------ ผลรางวัลล่าสุด ------
            const Text(
              "ผลรางวัลล่าสุด",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: brand),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blue, width: 2),
              ),
              color: const Color(0xFFEAF2FF),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("รางวัล",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("เลขที่ออก",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("เงินรางวัล",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ]),

                    // ที่ 1
                    TableRow(children: [
                      const Padding(
                          padding: EdgeInsets.all(6), child: Text("ที่ 1")),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          rFirst ?? '-',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text((prize1Amount ?? (_prize1.text) ?? "0")),
                      ),
                    ]),

                    // ที่ 2
                    TableRow(children: [
                      const Padding(
                          padding: EdgeInsets.all(6), child: Text("ที่ 2")),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(rSecond ?? '-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text((prize2Amount ?? (_prize2.text) ?? "0")),
                      ),
                    ]),

                    // ที่ 3
                    TableRow(children: [
                      const Padding(
                          padding: EdgeInsets.all(6), child: Text("ที่ 3")),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(rThird ?? '-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text((prize3Amount ?? (_prize3.text) ?? "0")),
                      ),
                    ]),

                    // เลขท้าย 3 ตัว
                    TableRow(children: [
                      const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text("เลขท้าย 3 ตัว")),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(rLast3 ?? '-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text((last3Amount ?? (_last3.text) ?? "0")),
                      ),
                    ]),

                    // เลขท้าย 2 ตัว
                    TableRow(children: [
                      const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text("เลขท้าย 2 ตัว")),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(rLast2 ?? '-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text((last2Amount ?? (_last2.text) ?? "0")),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
