import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dali/dali_cache_manager.dart';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:dali/cached_image.dart';
import 'package:path_provider/path_provider.dart';

class DaliImageProvider extends ImageProvider<DaliKey> {
  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  /// When the image fails to load [errorListener] is called.
  static bool debug = false;

  DaliImageProvider(this.url, {this.width, this.height, this.errorListener, this.scale = 1.0})
      : assert(url != null),
        assert(scale != null);

  /// Web url of the image to load
  final String url;

  /// Scale of the image
  final double scale;

  final int width;
  final int height;

  static DaliCacheManager cacheManager;

  /// Listener to be called when images fails to load.
  final ErrorListener errorListener;

  @override
  Future<DaliKey> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<DaliKey>(DaliKey(url, scale, width, height));
  }

  @override
  ImageStreamCompleter load(DaliKey key) {
    if (debug) print("load!!!!");
    try {
      return new MultiFrameImageStreamCompleter(
          codec: _loadAsync(key),
          scale: key.scale,
          informationCollector: (StringBuffer information) {
            information.writeln('Image provider: $this');
            information.write('Image key: $key');
          });
    } catch (e) {
      if (debug) print(e);
      if (errorListener != null) errorListener();

      return null;
    }
  }

  Future<ui.Codec> _loadAsync(DaliKey key) async {
    /*var cacheManager = await CacheManager.getInstance();
    var file = await cacheManager.getFile(url, headers: headers);*/
    if (cacheManager == null) {
      cacheManager = DaliCacheManager(cacheFolder: (await getTemporaryDirectory()).path, downloader: DownloaderImpl());
    }
    try {
      File file = await cacheManager.getFile(url, width, height, scale);
      return await _loadAsyncFromFile(key, file);
    } catch (e) {
      if (debug) print(e);
      if (errorListener != null) errorListener();
    }
    return null;
  }

  Future<ui.Codec> _loadAsyncFromFile(DaliKey key, File file) async {
    assert(key.hashCode == this.hashCode);

    final Uint8List bytes = await file.readAsBytes();
    if (debug) print("size: ${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB");
    if (bytes.lengthInBytes == 0) {
      if (errorListener != null) errorListener();
      throw new Exception("File was empty");
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DaliKey && url == other.url && scale == other.scale && width == other.width &&
              height == other.height;

  @override
  int get hashCode => url.hashCode ^ scale.hashCode ^ width.hashCode ^ height.hashCode;

  @override
  String toString() => '$runtimeType("$url", scale: $scale, size: ($width,$height))';
}

class DaliKey {
  final String url;
  final double scale;
  final int width;
  final int height;

  DaliKey(this.url, this.scale, this.width, this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DaliKey && url == other.url && scale == other.scale && width == other.width &&
              height == other.height;

  @override
  int get hashCode => url.hashCode ^ scale.hashCode ^ width.hashCode ^ height.hashCode;
}
