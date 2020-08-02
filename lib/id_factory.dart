import 'shuffler.dart';

class IdFactory implements Shuffler {
  final _total;
  int dir, id;
  IdFactory(this._total);

  int next() {
    id += dir;
    if (id > _total - 1) {
      id = _total - 1;
    }
    if (id < 0) {
      id = 0;
    }
    return id;
  }
}