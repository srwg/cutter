import 'dart:ffi';

import 'dart:io';

import 'dart:typed_data';

class ImageData {
  int merit;
  int rotation;
  int index;
  int dx, dy, w, h;

  ImageData(RandomAccessFile f) {
    final b = f.readSync(16);
    merit = b[0] >> 2;
    rotation = (b[0] & 3) * 90;
    index = ((b[1] & 0xFF) << 16) | ((b[2] & 0xFF) << 8) | (b[3] & 0xFF);
    final tokens = b.sublist(4,12).buffer.asInt16List();
    dx = tokens[0];
    dy = tokens[1];
    w = tokens[2];
    h = tokens[3];
    print([merit, rotation, dx, dy, w, h]);
  }

  void setMerit(int merit) {
    this.merit = merit;
  }

  void save(RandomAccessFile f) {
    final b = ByteData(16);
    b.setUint32(0, index);
    b.setUint8(0, (merit * 4  + rotation ~/ 90) & 15);
    b.setInt16(4, dx);
    b.setInt16(6, dy);
    b.setInt16(8, w);
    b.setInt16(10, h);
    f.writeFromSync(b.buffer.asUint32List());
  }
}