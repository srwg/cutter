import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as image;

import 'package:path_provider/path_provider.dart';

import 'image_data.dart';
import 'image_index.dart';

class ImageLoader {
  List<ImageData> rawdata = [];
  List<List<ImageData>> _packedData = [];
  final _imageIndex = <ImageIndex>[];
  int _cur = -1;
  String path;
  RandomAccessFile _dat;
  bool modified = false;

  Future init() async {
    path = (await getApplicationDocumentsDirectory()).path + '/';
    final f = File(path + 'dir').openSync();
    final n = f.lengthSync() ~/ 16;
    for (int i = 0; i < n; ++i) {
      var data = ImageData(f);
      rawdata.add(data);
      while (_packedData.length < data.index + 1) {
        _packedData.add(<ImageData>[]);
      }
      _packedData[data.index].add(data);
    }
    f.close();
    for (int i = 0; i < 32; ++i) {
      _imageIndex.add(null);
    }
  }

  int getPackedN() => _packedData.length;

  bool isUnprocessedPack(int id) => _packedData[id].any((d) => d.merit == 3);

  Uint8List getImagePack(int id) => _getImage(_packedData[id][0].index);

  Uint8List _getImage(int index) {
    final n = index ~/ 10000;
    if (n != _cur) {
      _cur = n;
      _dat = File('$path$n.dat').openSync();
    }
    if (_imageIndex[n] == null) {
      _imageIndex[n] = ImageIndex(path, n);
    }
    final start = _imageIndex[n].start[index % 10000];
    final length = _imageIndex[n].start[index % 10000 + 1] - start;
    _dat.setPositionSync(start);
    return _dat.readSync(length);
  }

  List<ImageData> getDataPack(int id) => _packedData[id];

  void saveAllPacks() {
    if (!modified) return;
    print('************** hahaha');
    final f = File(path + 'dir').openSync(mode: FileMode.write);
    for (var dataList in _packedData) {
      for (var data in dataList) {
        data.save(f);
      }
    }
    modified = false;
  }

  int getN() => rawdata.length;

  int getMerit(int id) => rawdata[id].merit;

  Uint8List getImage(int id) {
    var data = rawdata[id];
    var rawImage = _getImage(data.index);
    return image.encodeJpg(image.copyCrop(
        image.copyRotate(image.decodeImage(rawImage), data.rotation),
        data.dx,
        data.dy,
        data.w,
        data.h));
  }
}
