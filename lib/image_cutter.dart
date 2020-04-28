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
  List<int> _idList = [];

  void init() async {
    if (_inited) return;
    _inited = true;
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    _loader = ImageLoader();
    WidgetsBinding.instance.addObserver(this);
    _total = _loader.getN();
    _count = 0;
    _idFactory = new Shuffler(_total);
    _next();
  }

  void _next() async {
    if (_id != null) {
      _idList.add(_id);
    }
    _clicked = false;
    _id = _idFactory.next();
    ++_count;
    /*
    while (!_loader.isUnprocessed(_id)) {
      _id = _idFactory.next();
      ++_count;
    }*/
    _show();
  }

  void _show() {
    _data = _loader.getData(_id);
    _dataId = 0;
    _painter.setImage(_loader.getImage(_id), '$_count / $_total');
    _painter.setData(_data, _dataId);
  }

  void _prev() async {
    _id = _idList.removeLast();
    if (_id != null) {
      _show();
    }
  }

  void _rotate() async {
    _painter.rotate();
  }

  void _save() {
    _painter.save();
    _isSelected[1] = true;
  }

  void _delete() {

  }

  void _add() {
    _isSelected[1] = false;
    _dataId++;
    _painter.setData(_data, _dataId);
  }

  void _defer() {}

  final _isSelected = [false, false, false, false, false, false, false];
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
            onTap: () => _painter.redrawImage(),
            child: CustomPaint(
              painter: _painter,
            ),
          ),
        Positioned(
          top: width * 16 / 9.0,
          child: Container(
            height: 1.0,
            width: width,
            color: Colors.amberAccent,
          )
        ),
        Positioned(
          bottom: 10.0,
          left: 0.0,
          child: ToggleButtons(
            borderColor: Color.fromARGB(0, 0, 0, 0),
            children:[
              Icon(Icons.skip_previous),
              Icon(Icons.save),
              Icon(Icons.add),
              Icon(Icons.delete),
              Icon(Icons.pause),
              Icon(Icons.rotate_right),
              Icon(Icons.skip_next),
            ],
            onPressed: (index) {
              switch(index) {
                case 0: _prev(); break;
                case 1: _save(); break;
                case 2: _add(); break;
                case 3: _delete(); break;
                case 4: _defer(); break;
                case 5: _rotate(); break;
                case 6: _next(); break;
                default: break;
              }
            },
            isSelected: _isSelected,
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
