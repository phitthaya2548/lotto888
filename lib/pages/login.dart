import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/pages/admin/widgets/nav_admin.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/widgets/bottom_nav.dart';

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
    Configuration.getConfig().then(
      (config) {
        url = config['apiEndpoint'];
      },
    );
  }

  Future<void> login() async {
    if (url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API endpoint ยังไม่พร้อม')),
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final uri = Uri.parse('$url/login');

      final resp = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(Requestlogin(
              username: _username.text.trim(),
              password: _passCtrl.text.trim(),
            ).toJson()),
          )
          .timeout(const Duration(seconds: 15));

      // ตรวจว่าเป็น JSON จริงไหม
      final isJson =
          (resp.headers['content-type'] ?? '').toLowerCase().contains('json');

      if (resp.statusCode == 200) {
        dynamic body;
        try {
          body = isJson ? jsonDecode(resp.body) : resp.body;
        } catch (_) {
          body = resp.body;
        }

        late final res;
        if (body is Map<String, dynamic> || body is Map) {
          res = responseloginFromJson(jsonEncode(body));
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('รูปแบบคำตอบไม่ถูกต้อง (ไม่ใช่ JSON)')),
          );
          return;
        }

        final role = (res.user.role ?? '').toString().trim().toUpperCase();

        await AuthService.saveSession(res);

        if (!mounted) return;

        Widget nextPage;
        switch (role) {
          case 'ADMIN':
            nextPage = const AdminNav();
            break;
          case 'MEMBER':
          default:
            nextPage = const MemberShell();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );
      } else {
        String msg = 'เข้าสู่ระบบไม่สำเร็จ (${resp.statusCode})';
        if (isJson) {
          try {
            final m = jsonDecode(resp.body);
            final maybeMsg = (m is Map) ? (m['message'] ?? m['error']) : null;
            if (maybeMsg != null && maybeMsg.toString().trim().isNotEmpty) {
              msg = maybeMsg.toString();
            }
          } catch (_) {}
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เครือข่ายช้า/หมดเวลาเชื่อมต่อ (15s)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ผิดพลาด: $e')),
      );
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
                                              AlwaysStoppedAnimation<Color>(Colors.white),
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
