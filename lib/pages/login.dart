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
  void dispose() {
    _username.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API endpoint ยังไม่พร้อม')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final resp = await http.post(
        Uri.parse('$url/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(Requestlogin(
          username: _username.text.trim(),
          password: _passCtrl.text,
        ).toJson()),
      );

      if (resp.statusCode == 200) {
        final res = responseloginFromJson(resp.body);
        final prefs = await SharedPreferences.getInstance();
        log("role = ${res.user.role}");
        final role = (res.user.role ?? '').toString().toUpperCase();
        Widget nextPage;
        switch (role) {
          case 'ADMIN':
            nextPage = const AdminNav();
            break;
          case 'MEMBER':
            nextPage = const MemberShell();
            break;
          default:
            nextPage = const MemberShell();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );
        await AuthService.saveSession(res);
      } else {
        final msg = (jsonDecode(resp.body)['message'] ??
                'เข้าสู่ระบบไม่สำเร็จ (${resp.statusCode})')
            .toString();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ผิดพลาด: $e')),
      );
    }

    setState(() => _busy = false);
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
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.contain,
                      )),
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
                            const SizedBox(height: 0),
                            Row(
                              children: const [
                                Expanded(
                                  child: Divider(
                                    thickness: 2,
                                    color: Color(0xFF0593FF),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 60,
                                  ),
                                  child: Text(
                                    "",
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 2,
                                    color: Color(0xFF0593FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 50,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 130,
                                    top: -40,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Google Sign-In (demo)")),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 228, 241, 253),
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 6,
                                                offset: Offset(0, 2)),
                                          ],
                                        ),
                                        child: Image.asset(
                                          'assets/images/google.png',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
