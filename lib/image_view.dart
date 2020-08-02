import 'dart:async';
import 'dart:math';

import 'package:cutter/id_factory.dart';
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
  final _random = Random();
  Shuffler _idFactory, _shuffler;
  int _id, _total, _merit;
  List<int> _image;
  List<int> _idHistory = [];
  Timer _timer;
  int _countDown = 2;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _total = widget.loader.getN();
    _shuffler = new Shuffler(_total);
    _idFactory = _shuffler;
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
      widget.loader.saveAllPacks();
      _timer.cancel();
      Wakelock.disable();
    } else if (state == AppLifecycleState.resumed) {
      _timer = Timer.periodic(Duration(seconds: 1), _onTime);
      Wakelock.enable();
    }
  }

  void _onTime(Timer _) {
    --_countDown;
    if (_countDown == 0) {
      _next();
    }
  }

  void _next() async {
    if (_id != null) {
      _idHistory.add(_id);
    }
    while (true) {
      _id = _idFactory.next();
      _merit = widget.loader.getMerit(_id);
      if (!_canShow()) continue;
      _show();
      break;
    }
  }

  bool _canShow() {
    if (_merit == 0 || _merit == 3) return false;
    return _random.nextInt(2) < _merit;
  }

  void _show() {
    _image = widget.loader.getImage(_id);
    _countDown = _merit == 3 ? 3 : _merit + 4;
    setState(() {});
  }

  void _prev(_) async {
    if (_idHistory.isNotEmpty) {
      _id = _idHistory.removeLast();
      _merit = widget.loader.getMerit(_id);
      _show();
    }
  }

  void _setMerit(double m) {
    _merit = m.round();
    widget.loader.setMerit(_id, _merit);
    setState(() {});
  }

  void _idMode(int d) {
    if (d == 0) {
      _idFactory = _shuffler;
    } else {
      _idFactory = IdFactory(_total)
        ..id = _id
        ..dir = d;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = height * 600 / 1024;
    if (_image == null) return Container();
    return Material(
      child: Center(
          child: Row(children: [
            Expanded(
              child: Container(),
            ),
        SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _next,
                  onHorizontalDragEnd: _prev,
                  child: Image.memory(_image,
                      width: width, height: height, fit: BoxFit.fitWidth),
                ),
                Positioned(
                    bottom: 50.0,
                    width: width,
                    child: Slider(
                        value: _merit * 1.0,
                        onChanged: _setMerit,
                        max: 3.0,
                        divisions: 3)),
              ],
            )),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RaisedButton(
                onPressed: () => _idMode(1),
                child: Icon(Icons.arrow_forward_ios),
              ),
              RaisedButton(
                onPressed: () => _idMode(0),
                child: Icon(Icons.arrow_drop_down_circle),
              ),
              RaisedButton(
                onPressed: () => _idMode(-1),
                child: Icon(Icons.arrow_back_ios),
              ),
              Expanded(
                child: Container(),
              ),
              RaisedButton(
                onPressed: () {
                  _timer.cancel();
                  Wakelock.disable();
                  Navigator.pop(context);
                },
                child: Icon(Icons.keyboard_return),
              ),
            ],
          ),
        )
      ])),
    );
  }
}
