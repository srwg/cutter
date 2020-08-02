import 'dart:io';

import 'package:flutter/material.dart';

import 'image_data.dart';
import 'image_loader.dart';
import 'image_painter.dart';
import 'shuffler.dart';

class ImageCutter extends StatefulWidget {
  final ImageLoader loader;

  ImageCutter(this.loader);

  @override
  _ImageCutterState createState() => _ImageCutterState();
}

class _ImageCutterState extends State<ImageCutter> with WidgetsBindingObserver {
  ImageLoader _loader;
  ImagePainter _painter;
  List<ImageData> _data;
  Shuffler _idFactory;
  int _id, _dataId;
  int _count;
  int _total;
  String _info = 'N/A';
  List<int> _idList = [];

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _loader = widget.loader;
    _painter = ImagePainter(
        (match) => WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _isSelected[5] = !match);
            }));
    _total = _loader.getPackedN();
    _count = 0;
    _idFactory = new Shuffler(_total);
    _next();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _loader.saveAllPacks();
    }
  }

  void _next() async {
    if (_id != null) {
      _loader.modified = true;
      _idList.add(_id);
      if (_data[_dataId].merit == 3) {
        _data[_dataId].merit = 0;
      }
    }
    _id = _idFactory.next();
    ++_count;
    while (_count <= _total && !_loader.isUnprocessedPack(_id)) {
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
    _data = _loader.getDataPack(_id);
    _painter.setImage(_loader.getImagePack(_id));
    _dataId = last ? _data.length - 1 : 0;
    _show();
  }

  void _show() {
    _painter.setData(_data, _data[_dataId]);
  }

  void _rotate() async {
    _painter.rotate();
  }

  void _save() {
    if (!_isSelected[5]) {
      return;
    }
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
    _painter.write(
        File(_loader.path + '$_id.jpg').openSync(mode: FileMode.writeOnly));
    _data.forEach((d) => d.merit = 0);
    _next();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          _loader.saveAllPacks();
          return true;
        },
        child: _app(context),
      );

  final _isSelected = [false, false, false, false, false, true, false];

  Widget _app(BuildContext context) {
    /*
    final width = MediaQuery.of(context).size.width;
    final height = width * 1024 / 600;
     */
    final height = MediaQuery.of(context).size.height - 70.0;
    final width = height * 600 / 1024;
    _painter.setBoundary(width, height);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: width,
          height: height,
          child: GestureDetector(
            onScaleStart: _painter.onScaleStart,
            onScaleUpdate: _painter.onScaleUpdate,
            onTap: () => _painter.redrawImage(),
            child: CustomPaint(
              painter: _painter,
            ),
          ),
        ),
        Container(
          height: 1,
          width: width,
          color: Colors.amber,
        ),
        ToggleButtons(
          borderColor: Color.fromARGB(0, 0, 0, 0),
          selectedColor: Colors.red,
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
            setState(
                () => _info = '$_count / $_total [$_dataId / ${_data.length}]');
          },
          isSelected: _isSelected,
        ),
        Text(_info),
      ]),
      Container(
        height: height,
        width: 10,
        color: Colors.amber,
      ),
      RaisedButton(
          onPressed: () {
            Navigator.pushNamed(context, 'view');
          },
          child: Icon(Icons.accessibility))
    ]);
  }
}
