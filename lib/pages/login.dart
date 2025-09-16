import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/pages/admin/widgets/nav_admin.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../models/request/req_login.dart';
import '../models/response/res_login.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _busy = false;
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = (config['apiEndpoint'] ?? '').toString();
    });
  }

  // ---- เพิ่ม helper สำหรับยิง HTTP + log ผล ----
  Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    debugPrint('[HTTP] POST $uri');
    if (headers != null) debugPrint('[HTTP] headers: $headers');
    if (body != null) debugPrint('[HTTP] body(out): $body');
    try {
      final resp = await http.post(uri, headers: headers, body: body);
      final ct = (resp.headers['content-type'] ?? '').toLowerCase();
      final head =
          resp.body.length > 300 ? resp.body.substring(0, 300) : resp.body;
      debugPrint('[HTTP] <- ${resp.statusCode} ct=$ct');
      debugPrint('[HTTP] body(head): $head');
      return resp;
    } catch (e, st) {
      debugPrint('[HTTP] EXCEPTION: $e\n$st');
      rethrow;
    }
  }

// ---- แทนที่ฟังก์ชัน login() เดิม ----
  Future<void> login() async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API endpoint ยังไม่พร้อม')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      // ทำให้ base url สะอาด (ตัด / ท้ายๆ ออก)
      final base = url.replaceAll(RegExp(r'/+$'), '');

      final resp = await _post(
        Uri.parse('$base/login'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': _username.text.trim(),
          'password': _passCtrl.text,
        }),
      );

      final ct = (resp.headers['content-type'] ?? '').toLowerCase();
      final isJson = ct.contains('application/json');

      if (resp.statusCode == 200 && isJson) {
        final res = responseloginFromJson(resp.body);

        // บันทึก session ก่อน แล้วค่อยนำทาง
        await AuthService.saveSession(res);

        final role = (res.user.role ?? '').toString().toUpperCase();
        Widget nextPage;
        switch (role) {
          case 'ADMIN':
            nextPage = const AdminNav();
            break;
          case 'MEMBER':
          default:
            nextPage = const MemberShell();
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );
      } else {
        // ถ้าไม่ใช่ JSON อย่าพยายาม jsonDecode — แสดงแค่ status
        final msg = isJson
            ? (jsonDecode(resp.body)['message'] ??
                    'เข้าสู่ระบบไม่สำเร็จ (${resp.statusCode})')
                .toString()
            : 'เข้าสู่ระบบไม่สำเร็จ (${resp.statusCode})';
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF0593FF);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7EC3FF), Color(0xFF59AFFB)],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Login\nto Lotto 888",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: brand,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _username,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    'assets/images/email.png',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                labelText: "Username",
                                labelStyle: const TextStyle(
                                  color: CupertinoColors.inactiveGray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ), //

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 217, 230, 247),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 217, 230, 247),
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: !_showPass,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    'assets/images/lock.png',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                labelText: "Password",
                                labelStyle: const TextStyle(
                                  color: CupertinoColors.inactiveGray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _showPass = !_showPass),
                                  icon: Icon(_showPass
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  color: brand,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 217, 230, 247),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 217, 230, 247),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (v) => (v != null && v.isNotEmpty)
                                  ? null
                                  : "กรอกรหัสผ่าน",
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
                                  login();
                                },
                                child: _busy
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.6,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Forgot password? (demo)")),
                                );
                              },
                              child: const Text("Forgot password?",
                                  style: TextStyle(color: brand)),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Register(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: brand,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
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
