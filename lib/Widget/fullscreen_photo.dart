import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GambarProgress extends StatelessWidget {
  final String gambar;

  const GambarProgress({Key? key, required this.gambar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(gambar),
      ),
    );
  }
}
