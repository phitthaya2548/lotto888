import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/config/config.dart';
import 'package:lotto/models/response/res_profile.dart';
import 'package:lotto/pages/auth_service.dart';
import 'package:lotto/pages/home_lotto.dart';
import 'package:lotto/pages/member/edit_profille.dart';
import 'package:lotto/widgets/app_drawer.dart';
import 'package:lotto/widgets/app_header.dart';

class ProfileLotto extends StatefulWidget {
  const ProfileLotto({super.key});

  @override
  State<ProfileLotto> createState() => _ProfileLottoState();
}

class _ProfileLottoState extends State<ProfileLotto> {
  String? _username;
  int? _userId;
  bool _loading = true;
  String url = "";
  static const brand = Color(0xFF007BFF);

  String _baseUrl = '';

  ResponseRandomProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final cfg = await Configuration.getConfig();
      final idStr = await AuthService.getId();
      final userId = idStr != null ? int.tryParse(idStr) : null;

      setState(() {
        _baseUrl = (cfg['apiEndpoint'] ?? '')
            .toString()
            .replaceAll(RegExp(r'/+$'), '');
      });

      if (_baseUrl.isEmpty || userId == null || userId <= 0) {
        log('invalid baseUrl/userId');
        return;
      }

      final uri = Uri.parse("$_baseUrl/users/profile/$userId");
      final resp = await http.get(uri, headers: {'Accept': 'application/json'});
      if (resp.statusCode != 200) {
        log("fetch profile failed: ${resp.statusCode} ${resp.body}");
        return;
      }

      final data = responseRandomProfileFromJson(resp.body);
      if (!mounted) return;
      setState(() {
        _profile = data;
      });
    } catch (e, st) {
      log('loadUser error: $e\n$st');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LottoHome()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF007BFF);
    final user = _profile?.user;
    final balance = _profile?.wallet.balance ?? 0.0;
    final ticketsTotal = _profile?.tickets.total ?? 0;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppHeader(),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      color: brand,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 40, color: Colors.black54),
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      user != null
                                          ? "${user.fullName}"
                                          : "กำลังโหลด...",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 100,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/bitcoin.png',
                                      width: 32, height: 32),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${(balance)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const Text("พอยต์"),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/tiket1.png',
                                      width: 32, height: 32),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$ticketsTotal",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const Text("สลากของฉัน"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ข้อมูลมาชิก',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()),
                    );
                    if (updated != null) {
                      _loadUser();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Image.asset('assets/images/account_circle.png',
                            fit: BoxFit.cover),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text("ข้อมูลส่วนตัว",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _logout,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Image.asset('assets/images/leave.png',
                            fit: BoxFit.cover),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text("ออกจากระบบ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


