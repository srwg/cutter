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
    if (image != null) {
      _image = image;
      _info = TextSpan(text: info);
    }
    _offset = Offset.zero;
    _zoom = 1.0 * H / _image.height;
    notifyListeners();
  }

  void _postProcess() {
    /*
    if (_offset.dx > 0 && _offset.dx < 20.0) {
      _offset = _offset.translate(-_offset.dx, 0.0);
    }
    final x = (_offset.dx + _image.width) * _zoom;
    if (x < W && x + 20.0 > W) {
      _zoom = W / (_offset.dx + _image.width);
    }*/
    if (_offset.dy > 0 && _offset.dy < 20.0) {
    _offset = _offset.translate(0.0, -_offset.dy);
    }
    final y = (_offset.dy + _image.height) * _zoom;
    if (y < H && y + 20.0 > H) {
      _zoom = H / (_offset.dy + _image.height);
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
