import 'package:flutter/material.dart';

import 'image_cutter.dart';

// Test
void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      appBar: AppBar(title: Text('Image cutter')),
      body: ImageCutter(),
    ),
  ));
}
