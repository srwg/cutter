import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/material.dart';

class ImageLoader {
  static const String _PATH =
      '/mnt/ext_sdcard/Android/data/com.rabbitxp.dat/files/screen/in/';

  static const List<int> _MRT = [48, 49, 50, 51, 52];

  int _n;
  List<int> _idx = [];
  Uint8List _mrt;
  RandomAccessFile _dat;
  RandomAccessFile _cut;

  void init() async {
    if (_n == null) {
      await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
      final File f = File(_PATH + '0/idx');
      _n = (await f.length()) ~/ 4 - 1;
      final ib = await f.readAsBytes();
      for (int i = 0; i < (_n + 1) * 4; i += 4) {
        var v = 0;
        for (int j = 0; j < 4; ++j) {
          v += ib[i + j] * pow(256, 3 - j);
        }
        _idx.add(v);
      }
      final File fm = File('/sdcard/cut/mrt');
      try {
        _mrt = await fm.readAsBytes();
      } catch (e) {
        _mrt = new Uint8List(_n);
        for (int i = 0; i < _n; ++i) {
          _mrt[i] = 120;
        }
      }
    }
    final File fd = File(_PATH + '0/dat');
    _dat = await fd.open();
    final File fc = File('/sdcard/cut/cut');
    _cut = await fc.open(mode: FileMode.append);
  }

  int getN() {
    return _n;
  }

  bool isUnprocessed(int id) {
    return _mrt[id] == 120;
  }

  Future<ui.Image> getImage(int id) async {
    await _dat.setPosition(_idx[id]);
    final list = await _dat.read(_idx[id + 1] - _idx[id]);
    return await decodeImageFromList(list);
  }

  void writeResult(String result) async {
    await _cut.writeString(result);
  }

  void setMerit(int id, int merit) {
    _mrt[id] = _MRT[merit];
  }

  void closeAll() {
    final File fm = File('/sdcard/cut/mrt');
    fm.writeAsBytesSync(_mrt);
    _dat.closeSync();
    _cut.closeSync();
  }
}
