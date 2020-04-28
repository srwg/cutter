import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cutter/image_data.dart';
import 'package:flutter/material.dart';

class ImagePainter extends ChangeNotifier implements CustomPainter {


  Offset _offset;
  Offset _previousOffset;
  Offset _zoomingOffset;

  double _zoom;
  double _previousZoom;
  double _w, _h;
  Offset _origin;

  ui.Image _image;
  String _info;
  String _info2;
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
      if (_data.rotation as int != 0) {
        canvas.rotate(-(_data.rotation as int) * math.pi / 180.0);
      }
      canvas.scale(_zoom);
      canvas.drawImage(_image, _offset, new Paint());
      final textPainter =
          TextPainter(text: TextSpan(text: _info + _info2), textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset.zero.translate(10.0, 50.0));
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

  List getCrop() {
    return [-_offset.dx, -_offset.dy, _w/_zoom, _h/_zoom];
  }

  void setImage(ui.Image image, String info) {
    if (image != null) {
      _image = image;
      _info = info;
      return;
    }
    _firstPan = 1;
    // TODO(support rotation!)
    _zoom = 1.0 * _h / _image.height;
    final x = math.max(1.0 * _w - _image.width * _zoom, 0.0);
    final y = math.max(1.0 * _h - _image.height * _zoom, 0.0);
    _offset = Offset.zero.translate(x, y) / _zoom;
    _previousOffset = _offset;
    notifyListeners();
  }

  void setData(List<ImageData> data, int dataId) {
    _data = data[dataId];
    _info2 = ' [$dataId / ${data.length}]';
    _firstPan = 1;
    if (_data.rotation as int == 0 || _data.rotation as int == 180) {
      _zoom = math.min(_w / (_data.w as double), _h / (_data.h as double));
    } else {
      _zoom = math.min(_w / (_data.h as double), _h/ (_data.w as double));
    }
    _offset = Offset.zero.translate(-(_data.dx as double), -(_data.dy as double));
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
