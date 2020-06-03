import 'dart:io';
import 'dart:math';

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
    index = (b[1] << 16) | (b[2] << 8) | b[3];
    dx = (b[4] << 8) | b[5];
    dy = (b[6] << 8) | b[7];
    w = (b[8] << 8) | b[9];
    h = (b[10] << 8) | b[11];
  }

  ImageData.from(ImageData x) {
    merit = 3;
    rotation = x.rotation;
    index = x.index;
    dx = x.dx;
    dy = x.dy;
    w = x.w;
    h = x.h;
  }

  void setMerit(int merit) {
    this.merit = merit;
  }

  void save(RandomAccessFile f) {
    if (merit == 0) return;
    final b = ByteData(16);
    b.setUint32(0, index, Endian.big);
    b.setUint8(0, (merit * 4 + rotation ~/ 90) & 15);
    b.setInt16(4, dx);
    b.setInt16(6, dy);
    b.setInt16(8, w);
    b.setInt16(10, h);
    f.writeFromSync(b.buffer.asUint8List());
  }

  static double _match1d(int x, int w, int xx, int ww) {
    final s = max(x, xx);
    final e = min(x + w, xx + ww);
    final l = max(w, ww);
    if (e < s) {
      return 0.0;
    }
    return (e - s) / l;
  }

  static bool _match(ImageData a, ImageData b) =>
      _match1d(a.dx, a.w, b.dx, b.w) + _match1d(a.dy, a.h, b.dy, b.h) > 1.75;

  bool match(Iterable<ImageData> d) =>
      d.any((d) => d.rotation == rotation && _match(this, d));
}
