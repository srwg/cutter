import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'image_data.dart';
import 'image_index.dart';

class ImageLoader {
  static const String CONFIG = '/sdcard/cutter';

  List<List<ImageData>> _imageData;
  final _imageIndex = <ImageIndex>[];
  int _cur = -1;
  String _path;
  List<int> _idx = [];
  Uint8List _mrt;
  RandomAccessFile _dat;

  ImageLoader() {

    _path = File(CONFIG).readAsStringSync().trim();
    final f = File(_path + 'dir').openSync();
    final n = f.lengthSync() ~/ 16;
    for (int i = 0; i < n; ++i) {
      var data = ImageData(f);
      while (_imageData.length < data.index) {
        _imageData.add(<ImageData>[]);
      }
      _imageData[data.index].add(data);
    }
    f.close();
    for (int i = 0; i < 32; ++i) {
      _imageIndex.add(null);
    }
  }

  int getN() {
    return _imageData.length;
  }

  bool isUnprocessed(int id) {
    return _imageData[id].any((d) => (d.merit as int) == 3);
  }

  Future<ui.Image> getImage(int id) async {
    final index = _imageData[id][0].index;
    final n = index ~/ 10000;
    if (n != _cur) {
      _cur = n;
      _dat = File('$_path$n.dat').openSync();
    }
    if (_imageIndex[n] == null) {
      _imageIndex[n] = ImageIndex(_path, n);
    }
    final start = _imageIndex[n].start[index % 10000];
    final length = _imageIndex[n].start[index % 10000 + 1] - start;
    _dat.setPositionSync(start);
    final b = _dat.readSync(length);
    return await decodeImageFromList(b);
  }

  List<ImageData> getData(int id) {
    return _imageData[id];
  }

  void saveAll() {
    final f = File(_path + 'dir').openSync(mode: FileMode.write);
    for (var dataList in _imageData) {
      for (var data in dataList) {
        data.save(f);
      }
    }
  }
}
