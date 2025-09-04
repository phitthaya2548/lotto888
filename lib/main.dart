import 'package:flutter/material.dart';
import 'package:lotto/pages/home_lotto.dart';
import 'package:lotto/pages/welcome_page.dart';
import 'package:lotto/widgets/bottom_nav.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ), 
      home: const MemberShell(),
    );
  }
}
