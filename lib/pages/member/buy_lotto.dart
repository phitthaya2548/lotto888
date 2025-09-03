import 'package:flutter/material.dart';

class BuyTicket extends StatefulWidget {
  const BuyTicket({Key? key}) : super(key: key);

  @override
  State<BuyTicket> createState() => _BuyTicketState();
}

class _BuyTicketState extends State<BuyTicket> {
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text('buy'),
      ),
      
    );
  }
}