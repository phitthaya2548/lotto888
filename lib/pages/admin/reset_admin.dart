import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lotto/pages/admin/widgets/app_headeradmin.dart';

class ResetAdmin extends StatefulWidget {
  const ResetAdmin({super.key});

  @override
  State<ResetAdmin> createState() => _ResetAdminState();
}

class _ResetAdminState extends State<ResetAdmin> {
  bool _busy = false;


  void _showConfirmReset() {
    Get.defaultDialog(
      title: "รีเซ็ทระบบ",
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
      radius: 12,
      backgroundColor: Colors.blue.shade50,
      barrierDismissible: false,
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ระบบจะลบข้อมูลออกทั้งหมด",
              style: TextStyle(fontSize: 16, color: Colors.black87)),
          SizedBox(height: 4),
          Text("• และจะจำลองระบบขึ้นมาใหม่",
              style: TextStyle(fontSize: 16, color: Colors.black87)),
          SizedBox(height: 12),
          Center(
            child: Text(
              "***คุณแน่ใจจะรีเซ็ทระบบใหม่ใช่มั้ย***",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Get.back(),
          child: const Text("ยกเลิก", style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _busy ? null : () async {
            Get.back();
            await _performReset();
          },
          child: const Text("ยืนยัน", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _performReset() async {
    setState(() => _busy = true);

    try {

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รีเซ็ทระบบสำเร็จ')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รีเซ็ทไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderAdmin(),
      backgroundColor: const Color(0xFFEAF2FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "รีเซ็ทระบบใหม่ทั้งหมด",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ",
                          style: TextStyle(fontSize: 16, color: Colors.black54)),
                      Expanded(
                        child: Text(
                          "ลบข้อมูลการซื้อ lotto ออกทั้งหมด",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ",
                          style: TextStyle(fontSize: 16, color: Colors.black54)),
                      Expanded(
                        child: Text(
                          "จะเหลือแค่ข้อมูลเจ้าของระบบ",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _busy ? null : _showConfirmReset,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "รีเซ็ทระบบ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
