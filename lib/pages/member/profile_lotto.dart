import 'package:flutter/material.dart';

class ProfileLotto extends StatelessWidget {
  const ProfileLotto({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D74FF);
    const lightBg = Color(0xFFF2F6FF);

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                color: const Color(0xFF2196F3),
                padding:
                    const EdgeInsets.only(left: 10, right: 10, bottom: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Image.asset("assets/images/smalllogo.png",
                          fit: BoxFit.cover, height: 40),
                      const SizedBox(width: 8),
                      const Text(
                        "Lotto 888",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------------- การ์ดเงินของฉัน ----------------
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("เงินของฉัน",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.credit_card, size: 30),
                        const SizedBox(width: 10),
                        const Text("0.00",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        _miniStat(Icons.monetization_on, "พอยต์", "0"),
                        _dividerV(),
                        _miniStat(Icons.confirmation_number, "สลากของฉัน", "0"),
                        _dividerV(),
                        _miniStat(Icons.local_activity, "คูปอง", "0"),
                      ],
                    )
                  ],
                ),
              ),

              // ---------------- คูปอง ----------------
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("คูปองส่วนลด",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                              "เก็บคูปอง", Icons.local_activity,
                              onTap: () {}),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionButton("ใส่รหัสคูปอง", Icons.key,
                              filled: true, onTap: () {}),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // ---------------- ข้อมูลสมาชิก ----------------
              _sectionCard(
                child: Column(
                  children: [
                    _listTile(Icons.person_outline, "ข้อมูลส่วนตัว",
                        onTap: () {}),
                    const Divider(height: 1),
                    _listTile(Icons.local_shipping_outlined, "ที่อยู่",
                        onTap: () {}),
                    const Divider(height: 1),
                    _listTile(Icons.logout, "ออกจากระบบ", color: Colors.red,
                        onTap: () {
                      // TODO: ใส่โค้ด logout
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Helper Widgets ----------------
  static Widget _sectionCard({required Widget child}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  static Widget _miniStat(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          )
        ],
      );

  static Widget _dividerV() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 1,
        height: 24,
        color: const Color(0xFFE0E0E0),
      );

  static Widget _actionButton(String text, IconData icon,
      {bool filled = false, VoidCallback? onTap}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? Colors.black : Colors.white,
        foregroundColor: filled ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }

  static Widget _listTile(IconData icon, String title,
      {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
