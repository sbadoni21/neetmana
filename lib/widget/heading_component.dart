import 'package:flutter/material.dart';
import 'package:matrimonial/utils/static.dart';

class HeadingTitle extends StatelessWidget {
  final String title;

  const HeadingTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}
