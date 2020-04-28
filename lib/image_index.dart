import 'dart:io';

import 'dart:typed_data';

class ImageIndex {
  ByteBuffer _b;
  List<int> start;

  ImageIndex(String path, int i) {
    final f = File('$path$i.idx');
    _b = f.readAsBytesSync().buffer;
    start = _b.asUint32List();
  }
}