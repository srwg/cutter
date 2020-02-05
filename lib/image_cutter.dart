import 'package:flutter/material.dart';

import 'image_loader.dart';
import 'image_painter.dart';
import 'shuffler.dart';

class ImageCutter extends StatelessWidget {
  final ImageLoader _loader = new ImageLoader();
  final ImagePainter _painter = new ImagePainter();
  Shuffler _idFactory;
  int _id;
  int _count;
  int _total;
  bool _clicked;

  void crop() {
    _clicked = true;
    final r = _painter.getCrop();
    _loader
        .writeResult('$_id\t${r[0]}\t${r[1].dx.round()}\t${r[1].dy.round()}\n');
  }

  void _next(int mrt) async {
    if (_id != null) {
      if (mrt > 1 && !_clicked) {
        return;
      }
      _loader.setMerit(_id, mrt);
    }
    if (_idFactory == null) {
      _total = _loader.getN();
      _count = 0;
      _idFactory = new Shuffler(_total);
    }
    _clicked = false;
    _id = _idFactory.next();
    ++_count;
    while (!_loader.isUnprocessed(_id)) {
      _id = _idFactory.next();
      ++_count;
    }
    _painter.setImage(await _loader.getImage(_id), '$_count / $_total');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onScaleStart: _painter.onScaleStart,
          onScaleUpdate: _painter.onScaleUpdate,
          onTap: () => _painter.setImage(null, null),
          onDoubleTap: crop,
          child: CustomPaint(
            painter: _painter,
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
                    onPressed: () => _next(4),
                    color: Color.fromRGBO(128, 255, 0, 0.1)),
                MaterialButton(
                    onPressed: () => _next(3),
                    color: Color.fromRGBO(128, 128, 128, 0.1)),
                MaterialButton(
                    onPressed: () => _next(1),
                    color: Color.fromRGBO(0, 128, 255, 0.1)),
                MaterialButton(
                    onPressed: () => _next(0),
                    color: Color.fromRGBO(255, 128, 128, 0.5)),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: Row(
            children: <Widget>[
              MaterialButton(
                  onPressed: _loader.closeAll,
                  color: Color.fromRGBO(128, 255, 0, 0.1)),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );
  }
}
