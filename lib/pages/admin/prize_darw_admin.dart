import 'package:flutter/material.dart';
import 'package:lotto/pages/admin/widgets/app_headeradmin.dart';

class PrizeDarwAdmin extends StatefulWidget {
  const PrizeDarwAdmin({super.key});

  @override
  State<PrizeDarwAdmin> createState() => _PrizeDarwAdminState();
}

class _PrizeDarwAdminState extends State<PrizeDarwAdmin> {
  int _mode = 0;

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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brand,
              ),
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

            Card(
              color: const Color(0xFFEAF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
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
                    _rewardRow("รางวัลที่ 1", "1,000,000"),
                    _rewardRow("รางวัลที่ 2", "1,000,000"),
                    _rewardRow("รางวัลที่ 3", "1,000,000"),
                    _rewardRow("เลขท้าย 3 ตัว", "1,000,000"),
                    _rewardRow("เลขท้าย 2 ตัว", "1,000,000"),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 82, 255, 87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: กดสุ่มรางวัล
                        },
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

            // การ์ดผลรางวัลล่าสุด
            const Text(
              "ผลรางวัลล่าสุด",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brand,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              color: const Color(0xFFEAF2FF),
              elevation: 0, // เอาเงาออกให้ดูเรียบ
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300, // สีเส้นในตาราง
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                  },
                  children: const [
                    TableRow(children: [
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
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("ที่ 1"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("123456"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("1,000,000"),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("ที่ 2"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("123456"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("2,000,000"),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("ที่ 3"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("123456"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("3,000,000"),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("เลขท้าย 3 ตัว"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("456"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("4,000,000"),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("เลขท้าย 2 ตัว"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("56"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("5,000,000"),
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

  Widget _rewardRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Icon(Icons.confirmation_number,
                color: Colors.black54, size: 20),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 16)),
          ]),
          Row(children: [
            Text(
              value,
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18),
              color: Colors.black54,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ],
      ),
    );
  }
}
