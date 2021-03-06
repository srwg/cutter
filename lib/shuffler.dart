import 'dart:math';

class Shuffler {
  final int _n;
  List<int> _a;
  int _cur = 0;
  final _random = Random();

  Shuffler(this._n) {
    _a = new List<int>(_n);
    for (int i = 0; i < _n; ++i) {
      _a[i] = i;
    }
  }

  int next() {
    if (_cur >= _n) {
      return _a[_n - 1];
    }
    final j = _random.nextInt(_n - _cur) + _cur;
    final tmp = _a[j];
    _a[j] = _a[_cur];
    return tmp;
  }
}