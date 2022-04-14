import 'package:flutter/material.dart';

class CustomLabel extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;

  CustomLabel({required this.text, this.fontSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: fontSize ?? 16, fontWeight: fontWeight ?? FontWeight.bold));
  }
}
