
import 'package:flutter/widgets.dart';


const int _kDefaultSize = 50;


class ImageCacheImpl extends ImageCache {
  final Map<Object, ImageStreamCompleter> _cache = <Object, ImageStreamCompleter>{};

  int get maximumSize => _maximumSize;
  int _maximumSize = _kDefaultSize;


  @override
  void clear() {
    _cache.clear();
  }

  @override
  ImageStreamCompleter putIfAbsent(Object key, ImageStreamCompleter loader()) {
    assert(key != null);
    assert(loader != null);
    print("putIfAbsent");
    ImageStreamCompleter result = _cache[key];
    if (result != null) {
      // Remove the provider from the list so that we can put it back in below
      // and thus move it to the end of the list.
      _cache.remove(key);
    } else {
      if (_cache.length == maximumSize && maximumSize > 0){
        _cache.remove(_cache.keys.first);
      }
      result = loader();
    }
    if (maximumSize > 0) {
      assert(_cache.length < maximumSize);
      _cache[key] = result;
    }
    assert(_cache.length <= maximumSize);
    return result;
  }
}
