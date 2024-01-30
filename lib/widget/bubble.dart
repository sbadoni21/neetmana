import 'package:flutter/material.dart';
import 'package:matrimonial/utils/static.dart';

class Bubble extends StatelessWidget {
  final String text;

  Bubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(82, 125, 89, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: myTextStylefontsize12white,
      ),
    );
  }
}
