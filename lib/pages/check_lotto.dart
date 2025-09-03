import 'package:flutter/material.dart';

class CheckLotto extends StatefulWidget {
  const CheckLotto({super.key});

  @override
  State<CheckLotto> createState() => _CheckLottoState();
}

class _CheckLottoState extends State<CheckLotto> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text('CheckPage'),
      ),
    );
  }
}
