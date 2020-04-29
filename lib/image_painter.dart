import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cutter/image_data.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

class ImagePainter extends ChangeNotifier implements CustomPainter {
  Offset _offset;
  Offset _previousOffset;
  Offset _zoomingOffset;

  double _zoom;
  double _previousZoom;
  double _w, _h;
  Offset _origin;
  int _rotation;

  Uint8List _rawImage;
  ui.Image _image;
  ImageData _data;

  int _firstPan;

  void setBoundary(double w, double h) {
    _w = w;
    _h = h;
    _origin = Offset.zero.translate(_w * 0.5, _h * 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_image != null) {
      _postProcess();
      canvas.scale(_zoom);
      canvas.drawImage(_image, _offset, new Paint());
    }
  }

  @override
  bool shouldRepaint(ImagePainter p) {
    return true;
  }

  void onScaleStart(ScaleStartDetails details) {
    --_firstPan;
    _zoomingOffset = details.focalPoint;
    _previousZoom = _zoom;
    _previousOffset = _offset;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if ((details.scale - 1.0) * (details.scale - 1.0) < 0.000001) {
      _offset = _previousOffset + (details.focalPoint - _zoomingOffset) / _zoom;
      notifyListeners();
      return;
    }
    _zoom = _previousZoom * details.scale;
    _offset = _previousOffset + _origin * (1.0 / _zoom - 1.0 / _previousZoom);
    notifyListeners();
  }

  void save(int merit) {
    _data.merit = merit;
    _data.rotation = _rotation;
    _data.dx = -_offset.dx.round();
    _data.dy = -_offset.dy.round();
    _data.w = (_w / _zoom).round();
    _data.h = (_h / _zoom).round();
    if (_data.dx + _data.w > _image.width) {
      _data.dx = _image.width - _data.w;
    }
    if (_data.dy + _data.h > _image.height) {
      _data.dy = _image.height - _data.h;
    }
  }

  void setImage(Uint8List data) {
    _rawImage = data;
  }

  void setData(ImageData data) async {
    _data = data;
    _rotation = _data.rotation;
    if (_data.rotation != 0) {
      _image = await decodeImageFromList(image.encodeJpg(
          image.copyRotate(image.decodeImage(_rawImage), _data.rotation)));
    } else {
      _image = await decodeImageFromList(_rawImage);
    }
    _drawImage();
  }

  void _drawImage() {
    _firstPan = -1;
    var dx = -1.0 * _data.dx;
    var dy = -1.0 * _data.dy;
    var w = _data.w;
    var h = _data.h;
    if (w > h) {
      dy += w * 1024 / 600 - h;
    }
    _zoom = math.min(_w / w, _h / h);
    _offset = Offset.zero.translate(dx, dy);
    _previousOffset = _offset;
    notifyListeners();
  }

  void rotate() async {
    _rotation += 90;
    if (_rotation == 360) _rotation = 0;
    if (_rotation != 0) {
      _image = await decodeImageFromList(image.encodeJpg(
          image.copyRotate(image.decodeImage(_rawImage), _rotation)));
    } else {
      _image = await decodeImageFromList(_rawImage);
    }
    redrawImage();
  }

  void redrawImage() {
    _firstPan = 1;
    _zoom = 1.0 * _h / _image.height;
    final x = math.max(1.0 * _w - _image.width * _zoom, 0.0);
    final y = math.max(1.0 * _h - _image.height * _zoom, 0.0);
    _offset = Offset.zero.translate(x, y) / _zoom;
    _previousOffset = _offset;
    notifyListeners();
  }

  void _postProcess() {
    /*
    if (_offset.dx > 0 && _offset.dx < 20.0) {
      _offset = _offset.translate(-_offset.dx, 0.0);
    }
    if (_offset.dy > 0 && _offset.dy < 20.0) {
    _offset = _offset.translate(0.0, -_offset.dy);
    }
    */
    if (_firstPan < 0) {
      if (_offset.dy < _previousOffset.dy) {
        _zoom = 1.0 /
            (1.0 / _previousZoom -
                (_previousOffset.dy - _offset.dy) / _origin.dy);
      }
    } else {
      _offset = _offset.translate(0.0, -_offset.dy);
    }
    final x = (_offset.dx + _image.width) * _zoom;
    if (x < _w) {
      _offset = _offset.translate((_w - x) / _zoom, 0.0);
    }
  }

  @override
  bool hitTest(ui.Offset position) {
    // TODO: implement hitTest
    return null;
  }

  @override
  // TODO: implement semanticsBuilder
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    // TODO: implement shouldRebuildSemantics
    return null;
  }
}
