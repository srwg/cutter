import 'package:flutter/material.dart';

import 'image_cutter.dart';


void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: ImageCutter(),
    ),
  ));
}