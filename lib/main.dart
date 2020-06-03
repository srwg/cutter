import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'image_cutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      appBar: AppBar(title: Text('Image cutter')),
      body: ImageCutter(),
    ),
  ));
}
