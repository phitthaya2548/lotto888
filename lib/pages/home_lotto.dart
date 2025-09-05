import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class LottoHome extends StatefulWidget {
  const LottoHome({Key? key}) : super(key: key);

  @override
  State<LottoHome> createState() => _LottoHomeState();
}

class _LottoHomeState extends State<LottoHome> {
  String? _selectedDraw;

  final List<DropdownMenuItem<String>> _drawItems = const [
    DropdownMenuItem(value: "2025-09-01", child: Text("1 กันยายน 2568")),
    DropdownMenuItem(value: "2025-08-16", child: Text("16 สิงหาคม 2568")),
  ];

  final List<String> digits = List.filled(6, '');

  void _checkLotto() {
    final number = digits.join();
    if (number.length != 6 || number.contains('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกเลขให้ครบ 6 หลัก')),
      );
      return;
    }
    if (_selectedDraw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกงวดวันที่')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('งวด: $_selectedDraw | เลขของคุณ: $number')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 300.0;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      drawer: const AppDrawer(),
      body: Builder(
        builder: (scaffoldCtx) => Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: headerHeight,
              color: const Color(0xFF2196F3),
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Image.asset(
                      "assets/images/smalllogo.png",
                      fit: BoxFit.cover,
                      height: 40,
                    ),
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
                  IconButton(
                    icon: const Icon(Icons.menu, size: 42, color: Colors.white),
                    onPressed: () => Scaffold.of(scaffoldCtx).openDrawer(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Card(
                clipBehavior: Clip.none,
                color: const Color(0xFFD3EAFF),
                margin: const EdgeInsets.only(top: 100, left: 15, right: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
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
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedDraw,
                          items: _drawItems,
                          decoration: InputDecoration(
                            labelText: "งวดวันที่ dd mmmm yyyy",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 115, 122, 128),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _selectedDraw = value),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 40,
                              child: TextField(
                                onChanged: (val) {
                                  if (val.isEmpty) return;
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
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 115, 122, 128),
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
                        ElevatedButton(
                          onPressed: _checkLotto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            "ตรวจสลากกินแบ่ง",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
