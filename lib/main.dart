import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:simple_permissions/simple_permissions.dart';

import 'image_cutter.dart';
import 'image_loader.dart';
import 'image_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

  final _loader = ImageLoader();
  await _loader.init();
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    routes: {
      'view': (context) => ImageView(_loader),
    },
    home: Scaffold(
      backgroundColor: Colors.lightBlue,
      body: ImageCutter(_loader),
    ),
  ));
}
