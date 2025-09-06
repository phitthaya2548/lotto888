import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
          
      toolbarHeight: 150,
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF007BFF),
      title: Row(
        children: [
          Image.asset("assets/images/smalllogo.png",
              fit: BoxFit.cover, height: 40),
          const SizedBox(width: 8),
          const Text(
            "Lotto 888",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 32, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }
}
