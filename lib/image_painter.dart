import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImagePainter extends ChangeNotifier implements CustomPainter {
  // The size of my KNL10.
  static const W = 360;
  static const H = 614;

  final _ORIGIN = Offset.zero.translate(W * 0.5, H * 1.0);

  Offset _offset;
  Offset _previousOffset;
  Offset _zoomingOffset;

  double _zoom;
  double _previousZoom;

  ui.Image _image;
  TextSpan _info;

  int _firstPan;

  @override
  void paint(Canvas canvas, Size size) {
    if (_image != null) {
      _postProcess();
      canvas.scale(_zoom);
      canvas.drawImage(_image, _offset, new Paint());
      final textPainter =
          TextPainter(text: _info, textDirection: TextDirection.ltr);
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
    _offset = _previousOffset + _ORIGIN * (1.0 / _zoom - 1.0 / _previousZoom);
    notifyListeners();
  }

  List getCrop() {
    return [_zoom * 1024.0 / H, -_offset * (1024.0 / H)];
  }

  void setImage(ui.Image image, String info) {
    bool yMode = true;
    if (image != null) {
      _image = image;
      _info = TextSpan(text: info);
      yMode = _image.height >= _image.width;
    }
    _firstPan = yMode ? 1 : -1;
    _zoom = yMode ? 1.0 * H / _image.height : 1.0 * W / _image.width;
    final x = max(1.0 * W - _image.width * _zoom, 0.0);
    final y = max(1.0 * H - _image.height * _zoom, 0.0);
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
                (_previousOffset.dy - _offset.dy) / _ORIGIN.dy);
      }
    } else {
      _offset = _offset.translate(0.0, -_offset.dy);
    }
    final x = (_offset.dx + _image.width) * _zoom;
    if (x < W) {
      _offset = _offset.translate((W - x) / _zoom, 0.0);
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
