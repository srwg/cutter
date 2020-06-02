import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'image_data.dart';
import 'image_loader.dart';
import 'image_painter.dart';
import 'shuffler.dart';

class ImageCutter extends StatefulWidget {
  @override
  _ImageCutterState createState() => _ImageCutterState();
}

class _ImageCutterState extends State<ImageCutter> {
  ImageLoader _loader;

  final ImagePainter _painter = new ImagePainter();

  List<ImageData> _data;

  Shuffler _idFactory;

  int _id, _dataId;

  int _count;

  int _total;

  String _info = 'N/A';

  List<int> _idList = [];

  @override
  initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    _loader = ImageLoader();
    _total = _loader.getN();
    _count = 0;
    _idFactory = new Shuffler(_total);
    _next();
  }

  void _next() async {
    if (_id != null) {
      _idList.add(_id);
      if (_data[_dataId].merit == 3) {
        _data[_dataId].merit = 0;
      }
    }
    _id = _idFactory.next();
    ++_count;
    while (_count <= _total && !_loader.isUnprocessed(_id)) {
      _id = _idFactory.next();
      ++_count;
    }
    _loadImage();
  }

  void _prev() async {
    _id = _idList.removeLast();
    if (_id != null) {
      _loadImage(last: true);
    }
  }

  void _loadImage({last: false}) {
    _data = _loader.getData(_id);
    _painter.setImage(_loader.getImage(_id));
    _dataId = last ? _data.length - 1 :0;
    _isSelected[5] = false;
    _show();
  }

  void _show() {
    _painter.setData(_data[_dataId]);
  }

  void _rotate() async {
    _painter.rotate();
  }

  void _save() {
    // TODO support merit change.
    _isSelected[5] = !_isSelected[5];
    _painter.save(2);
    _add();
  }

  void _delete() {
    if (_data.length == 1) {
      _data[_dataId].merit = 0;
      _next();
      return;
    }
    _data.removeAt(_dataId);
    if (_dataId > _data.length - 1) {
      _dataId = _data.length - 1;
    }
    _show();
  }

  void _add() {
    if (_data[_dataId].merit == 3) {
      return;
    }
    if (_dataId >= _data.length - 1) {
      _data.add(ImageData.from(_data[_dataId]));
    }
    ++_dataId;
    _show();
  }

  void _defer() {
    _painter.write(File('/sdcard/$_id.jpg').openSync(mode: FileMode.writeOnly));
    _data.forEach((d) => d.merit = 0);
    _next();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _loader.saveAll();
      return true;
    },
    child: _app(context),
  );

  final _isSelected = [false, false, false, false, false, false, false];

  Widget _app(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = width * 1024 / 600;
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
            top: width * 1024 / 600,
            child: Container(
              height: 1.0,
              width: width,
              color: Colors.amberAccent,
            )),
        Positioned(
          bottom: 12.0,
          left: 0.0,
          child: ToggleButtons(
            borderColor: Color.fromARGB(0, 0, 0, 0),
            children: [
              Icon(Icons.skip_previous),
              Icon(Icons.rotate_right),
              Icon(Icons.pause),
              Icon(Icons.delete),
              Icon(Icons.add),
              Icon(Icons.save),
              Icon(Icons.skip_next),
            ],
            onPressed: (index) {
              switch (index) {
                case 0:
                  _prev();
                  break;
                case 1:
                  _rotate();
                  break;
                case 2:
                  _defer();
                  break;
                case 3:
                  _delete();
                  break;
                case 4:
                  _add();
                  break;
                case 5:
                  _save();
                  break;
                case 6:
                  _next();
                  break;
                default:
                  break;
              }
              setState(() => _info =
                  '$_count / $_total [$_dataId / ${_data.length}]');
            },
            isSelected: _isSelected,
          ),
        ),
        Positioned(
          bottom: 0.0,
          right: 100.0,
          child: Text(_info),
        )
      ],
    );
  }
}
