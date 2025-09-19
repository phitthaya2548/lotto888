// lib/pages/profile/edit_profile.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/config/config.dart';
import 'package:lotto/models/request/req_profile.dart';
import 'package:lotto/models/response/res_profile.dart';
import 'package:lotto/pages/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const brand = Color(0xFF007BFF);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _baseUrl = '';
  int? _userId;
  bool _loading = true;
  bool _saving = false;

  ResponseRandomProfile? _profile;

  @override
  void initState() {
    super.initState();
    _setupThenLoad();
  }

  Future<void> _setupThenLoad() async {
    try {
      final cfg = await Configuration.getConfig();
      final idStr = await AuthService.getId();

      _baseUrl = (cfg['apiEndpoint'] ?? '')
          .toString()
          .replaceAll(RegExp(r'/+$'), '');
      _userId = idStr != null ? int.tryParse(idStr) : null;

      if (_userId == null || _userId! <= 0) {
        throw Exception('invalid userId');
      }

      await _bootstrap();
    } catch (e, st) {
      log('setup error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('โหลดโปรไฟล์ไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _bootstrap() async {
    final uri = Uri.parse('$_baseUrl/users/profile/${_userId!}');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});

    if (resp.statusCode != 200) {
      throw Exception('load profile failed: ${resp.statusCode} ${resp.body}');
    }

    final profile = responseRandomProfileFromJson(resp.body);
    _profile = profile;

    _nameCtrl.text = profile.user.fullName ?? '';
    _phoneCtrl.text = profile.user.phone ?? '';
    _emailCtrl.text = profile.user.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_baseUrl.isEmpty || _userId == null || _userId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยังพร้อมใช้งานไม่ครบ (baseUrl/userId)')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final uri = Uri.parse('$_baseUrl/users/edit/${_userId!}');
      final req = RequestProfileUpdate(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      final resp = await http.put(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(req.toJson()),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
        );

        _nameCtrl.text = req.fullName;
        _emailCtrl.text = req.email;
        _phoneCtrl.text = req.phone;

        Navigator.pop(context, {
          'full_name': req.fullName,
          'email': req.email,
          'phone': req.phone,
        });
      } else {
        String msg = 'บันทึกไม่สำเร็จ (${resp.statusCode})';
        try {
          final m = jsonDecode(resp.body);
          if (m is Map && m['message'] is String) msg = m['message'];
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, st) {
      log('save error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'กรุณากรอกชื่อ';
    if (s.length < 2) return 'ชื่อสั้นเกินไป';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'กรุณากรอกอีเมล';
    if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(s)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        backgroundColor: brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อมูลส่วนตัว',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 50, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('ชื่อ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(hintText: 'ชื่อ–นามสกุล'),
                    ),
                    const SizedBox(height: 16),

                    const Text('เบอร์',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(hintText: 'เช่น 0999999999'),
                    ),
                    const SizedBox(height: 16),

                    const Text('อีเมล',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _emailCtrl,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration:
                          const InputDecoration(hintText: 'name@example.com'),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('บันทึกข้อมูล',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

