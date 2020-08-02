import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wakelock/wakelock.dart';

import 'image_loader.dart';
import 'shuffler.dart';

class ImageView extends StatefulWidget {
  final ImageLoader loader;

  ImageView(this.loader);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> with WidgetsBindingObserver {
  Shuffler _idFactory;
  int _id, _total;
  List<int> _image;
  Timer _timer;
  int _countDown = 2;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _total = widget.loader.rawdata.length;
    _idFactory = new Shuffler(_total);
    _next();
    Wakelock.enable();
    _timer = Timer.periodic(Duration(seconds: 1), _onTime);
  }

  @override
  void dispose() {
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print('timer canceled');
      _timer.cancel();
      Wakelock.disable();
    } else if (state == AppLifecycleState.resumed) {
      print('app resumed');
      _timer = Timer.periodic(Duration(seconds: 1), _onTime);
      Wakelock.enable();
    }
  }

  void _onTime(Timer _) {
    --_countDown;
    if (_countDown == 0) {
      setState(() {
        _next();
      });
    }
  }

  void _next() async {
    while (true) {
      _id = _idFactory.next();
      var merit = widget.loader.getMerit(_id);
      if (merit == 0) continue;
      _image = widget.loader.getImage(_id);
      _countDown = merit == 3 ? 3 : merit + 3;
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = height * 600 / 1024;
    if (_image == null) return Container();
    return Center(
        child: SizedBox(
            width: width,
            height: height,
            child: GestureDetector(
              onTap: () => setState(() {
                _next();
              }),
              child: Image.memory(_image,
                  width: width, height: height, fit: BoxFit.fitWidth),
            )));
  }
}
