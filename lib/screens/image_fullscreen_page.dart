import 'package:flutter/material.dart';

class ImageEnlargedView extends StatefulWidget {
  final String? imageUrl; 

  ImageEnlargedView({Key? key, this.imageUrl}) : super(key: key);

  @override
  _ImageEnlargedViewState createState() => _ImageEnlargedViewState();
}

class _ImageEnlargedViewState extends State<ImageEnlargedView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Image.network(widget.imageUrl!),
        ),
      ),
    );
  }
}
