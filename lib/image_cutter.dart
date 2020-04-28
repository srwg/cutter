import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'image_data.dart';
import 'image_loader.dart';
import 'image_painter.dart';
import 'shuffler.dart';

class ImageCutter extends StatelessWidget with WidgetsBindingObserver {
  ImageLoader _loader;
  final ImagePainter _painter = new ImagePainter();
  List<ImageData> _data;
  Shuffler _idFactory;
  int _id, _dataId;
  int _count;
  int _total;
  bool _clicked;
  bool _inited = false;

  ImageCutter() {
    //init();
  }

  void init() async {
    if (_inited) return;
    _inited = true;
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    _loader = ImageLoader();
    WidgetsBinding.instance.addObserver(this);
    _total = _loader.getN();
    _count = 0;
    _idFactory = new Shuffler(_total);
    _id = null;
    _next();
  }

  void crop() {
    _clicked = true;
    // TODO
    //_loader.addCrop(_painter.getCrop());
  }

  void _next() async {
    _id = _idFactory.next();
    ++_count;
    while (!_loader.isUnprocessed(_id)) {
      _id = _idFactory.next();
      ++_count;
    }
    _data = _loader.getData(_id);
    _dataId = 0;
    _painter.setImage(await _loader.getImage(_id), '$_count / $_total');
    _painter.setData(_data, _dataId);
  }

  @override
  Widget build(BuildContext context) {
    init();

    final width = MediaQuery.of(context).size.width;
    final height = width * 16 / 9.0;
    _painter.setBoundary(width, height);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onScaleStart: _painter.onScaleStart,
          onScaleUpdate: _painter.onScaleUpdate,
          onTap: () => _painter.setImage(null, null),
          onDoubleTap: crop,
          child: Container(
            width: width,
            height: width * 16 / 9.0,
            child: CustomPaint(
              painter: _painter,
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          child: Container(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: <Widget>[
                MaterialButton(
                    onPressed: () => _next(),
                    color: Color.fromRGBO(128, 255, 0, 0.1)),
                MaterialButton(
                    onPressed: () => _next(),
                    color: Color.fromRGBO(128, 128, 128, 0.1)),
                MaterialButton(
                    onPressed: () => _next(),
                    color: Color.fromRGBO(0, 128, 255, 0.1)),
                MaterialButton(
                    onPressed: () => _next(),
                    color: Color.fromRGBO(255, 128, 128, 0.5)),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: MaterialButton(
            color: Color.fromRGBO(128, 255, 0, 0.1),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // TODO _loader.closeAll();
    } else if (state == AppLifecycleState.resumed) {
      // TODO _loader.init();
    }
  }
}
