import 'package:flutter/material.dart';

class CurrencyIcon extends StatelessWidget {
  const CurrencyIcon({this.size = 18, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      '💰',
      style: TextStyle(fontSize: size, height: 1),
    );
  }
}
