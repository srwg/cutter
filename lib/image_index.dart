import 'dart:io';

import 'dart:typed_data';

class ImageIndex {
  List<int> start = [];

  ImageIndex(String path, int i) {
    final f = File('$path$i.idx');
    final _b = ByteData.view(f.readAsBytesSync().buffer);
    for (int i = 0; i < _b.lengthInBytes; i+=4) {
      start.add(_b.getUint32(i));
    }
  }
}