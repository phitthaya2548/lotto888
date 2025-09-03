import 'package:flutter/material.dart';
import 'package:lotto/widgets/bottom_nav.dart';

class LottoHome extends StatefulWidget {
  const LottoHome({Key? key}) : super(key: key);

  @override
  State<LottoHome> createState() => _LottoHomeState();
}

class _LottoHomeState extends State<LottoHome> {
  bool _busy = false;

  // ตัวแปรสำหรับควบคุมค่าของช่องกรอกเลข
  final List<TextEditingController> _controllers = List.generate(
      6, (_) => TextEditingController(text: '9')); // ค่าเริ่มต้น '9'
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode()); // FocusNode สำหรับแต่ละช่องกรอก

  @override
  void dispose() {
    // อย่าลืม dispose focus nodes เมื่อ widget ถูกทำลาย
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  DateTime? _selectedDate; // สำหรับเลือกวันที่

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF0593FF);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotto 888'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // จัดให้อยู่ด้านบน
          crossAxisAlignment:
              CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางแนวนอน
          children: [
            // กรอบสำหรับแสดงผลสลาก
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFD3EAFF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 189, 182, 182),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'ตรวจผลสลากกินแบ่ง',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ช่องกรอกวันที่
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 50),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(28)),
                      child: Text(
                        _selectedDate != null
                            ? "งวดวันที่  ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                            : 'เลือกวันที่    > ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ช่องกรอกเลข 6 หลัก
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // จัดให้อยู่กลาง
                    children: List.generate(6, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0), // เพิ่มช่องว่างระหว่างช่องกรอก
                        child: SizedBox(
                          width: 45,
                          child: TextFormField(
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1, // จำกัดการกรอกที่ 1 ตัว
                            decoration: InputDecoration(
                              counterText: '', // ไม่แสดงจำนวนตัวอักษร
                              filled: true, // เปิดการใช้งานพื้นหลัง
                              fillColor: Colors.white, // กำหนดพื้นหลังเป็นสีขาว
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // ขอบโค้งมนที่ 12
                                borderSide: const BorderSide(
                                  color: Colors.grey, // สีของขอบ
                                  width: 2, // ความหนาของเส้นขอบ
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              // เมื่อผู้ใช้กรอกข้อมูล เลข '9' จะหายไป
                              if (value.isNotEmpty && value != '9') {
                                setState(() {
                                  // ห้ามให้กรอกเกิน 1 ตัว
                                  _controllers[index].text =
                                      value.substring(0, 1);
                                });
                              }
                            },
                            onTap: () {
                              // เมื่อคลิกที่ช่องกรอกให้เลข '9' หายไปทันที
                              if (_controllers[index].text == '9') {
                                setState(() {
                                  _controllers[index].clear(); // ลบเลข '9'
                                });
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: brand,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MemberShell(),
                          ),
                        );
                      },
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "ตรวจสลากฯ ของคุณ",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
