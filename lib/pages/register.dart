import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // สำหรับ inputFormatters
import 'package:http/http.dart' as http;
import 'package:lotto/pages/welcome_page.dart';
import '../config/config.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _money = TextEditingController();
  final _fullName = TextEditingController(); // เพิ่มตัวควบคุมสำหรับ full_name

  bool _showPass = false;
  bool _submitting = false;
  String? url;

  @override
  void initState() {
    super.initState();
    () async {
      final config = await Configuration.getConfig();
      setState(() {
        url = config['apiEndpoint'];
      });
    }();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _phone.dispose();
    _money.dispose();
    _fullName.dispose(); // เพิ่มการ dispose ของตัวควบคุม full_name
    super.dispose();
  }

  Future<void> register() async {
    if (url == null || url!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API endpoint ยังไม่พร้อม')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final payload = {
        "username": _username.text.trim(),
        "email": _email.text.trim(),
        "password": _password.text,
        "phone": _phone.text.trim(),
        "money": double.tryParse(_money.text.trim()) ?? 0,
        "full_name": _fullName.text.trim(), // เพิ่มฟิลด์ full_name
      };

      final resp = await http.post(
        Uri.parse('${url!}/register'),
        headers: const {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(payload),
      );

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data["message"]}')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data["message"] ?? "Register failed"}')),
          );
        }
      } else {
        String msg = 'Server error: ${resp.statusCode}';
        try {
          final m = jsonDecode(resp.body);
          if (m is Map && m['message'] is String) msg = m['message'];
        } catch (_) {}
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EC3FF), Color(0xFF59AFFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset("assets/images/Logo.png", fit: BoxFit.contain),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              "Register \nto Lotto 888",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1291FF),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Full Name
                            TextFormField(
                              controller: _fullName,
                              textInputAction: TextInputAction.next,
                              decoration: _decorate("Full Name", 'assets/images/user.png'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return "กรอกชื่อเต็ม";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Username
                            TextFormField(
                              controller: _username,
                              textInputAction: TextInputAction.next,
                              decoration: _decorate("Username", 'assets/images/User_alt.png'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "กรอก Username"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // Email
                            TextFormField(
                              controller: _email,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _decorate("Email", 'assets/images/email.png'),
                              validator: (v) {
                                final s = v?.trim() ?? '';
                                if (s.isEmpty) return "กรอก Email";
                                final re =
                                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                if (!re.hasMatch(s)) return "อีเมลไม่ถูกต้อง";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Phone
                            TextFormField(
                              controller: _phone,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: _decorate("Phone", 'assets/images/p1.png'),
                            ),
                            const SizedBox(height: 12),

                            // Money
                            TextFormField(
                              controller: _money,
                              textInputAction: TextInputAction.next,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                              decoration: _decorate("Money", 'assets/images/m1.png'),
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return "กรอกจำนวนเงินเริ่มต้น";
                                final n = double.tryParse(s);
                                if (n == null) return "ตัวเลขไม่ถูกต้อง";
                                if (n < 0) return "ต้องมากกว่าหรือเท่ากับ 0";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Password
                            TextFormField(
                              controller: _password,
                              textInputAction: TextInputAction.next,
                              obscureText: !_showPass,
                              decoration: _decorate(
                                "Password",
                                'assets/images/lock.png',
                                trailing: IconButton(
                                  onPressed: () =>
                                      setState(() => _showPass = !_showPass),
                                  icon: Icon(_showPass
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  color: const Color(0xFF1291FF),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "กรอกรหัสผ่าน";
                                if (v.length < 8) return "อย่างน้อย 8 ตัวอักษร";
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Confirm password
                            TextFormField(
                              controller: _confirm,
                              textInputAction: TextInputAction.done,
                              obscureText: !_showPass,
                              decoration: _decorate("Confirm Password", 'assets/images/lock.png'),
                              validator: (v) => (v == _password.text)
                                  ? null
                                  : "รหัสผ่านไม่ตรงกัน",
                            ),
                            const SizedBox(height: 10),

                            // Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  backgroundColor: const Color(0xFF1291FF),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _submitting ? null : register,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Text(
                                          "Register",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _submitting
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const WelcomePage()),
                                      ),
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 141, 135, 135),
                                  fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  InputDecoration _decorate(String label, String iconPath, {Widget? trailing}) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain),
      ),
      labelText: label,
      labelStyle: const TextStyle(
        color: CupertinoColors.inactiveGray,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      suffixIcon: trailing,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: Color(0xFF1291FF),
          width: 2,
        ),
      ),
    );
  }
}
