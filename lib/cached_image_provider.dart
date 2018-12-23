import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dali/dali_cache_manager.dart';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:dali/cached_image.dart';
import 'package:path_provider/path_provider.dart';

class CachedNetworkImageProvider extends ImageProvider<CachedNetworkImageProvider> {
  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  /// When the image fails to load [errorListener] is called.

  CachedNetworkImageProvider(this.url,
      {this.scale: 1.0, this.width, this.height, this.errorListener, this.headers})
      : assert(url != null),
        assert(scale != null);

  /// Web url of the image to load
  final String url;

  /// Scale of the image
  final double scale;

  final int width;
  final int height;
  final bool debug = true;

  DaliCacheManager cacheManager;

  /// Listener to be called when images fails to load.
  final ErrorListener errorListener;

  // Set headers for the image provider, for example for authentication
  final Map<String, String> headers;

  @override
  Future<CachedNetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<CachedNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(CachedNetworkImageProvider key) {
    if (debug) print("load!!!!");
    return new MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: key.scale,
        informationCollector: (StringBuffer information) {
          information.writeln('Image provider: $this');
          information.write('Image key: $key');
        });
  }


  Future<ui.Codec> _loadAsync(CachedNetworkImageProvider key) async {
    /*var cacheManager = await CacheManager.getInstance();
    var file = await cacheManager.getFile(url, headers: headers);*/
    if (cacheManager == null) {
      cacheManager =
      new DaliCacheManager(cacheFolder: (await getTemporaryDirectory()).path, downloader: DownloaderImpl());
    }
    var file = await cacheManager.getFile(url, width, height);

    if (file == null) {
      if (errorListener != null) errorListener();
      throw new Exception("Couldn't download or retreive file.");
    }
    try {
      return await _loadAsyncFromFile(key, file);
    } catch (e) {
      print(e);
      errorListener();
    }
    return null;
  }

  Future<ui.Codec> _loadAsyncFromFile(CachedNetworkImageProvider key, File file) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();
    if (debug) print("size: ${(bytes.lengthInBytes / (1024*1024)).toStringAsFixed(2)} MB");
    if (bytes.lengthInBytes == 0) {
      if (errorListener != null) errorListener();
      throw new Exception("File was empty");
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final CachedNetworkImageProvider typedOther = other;
    return url == typedOther.url && scale == typedOther.scale && width == this.width && height == this.height;
  }

  @override
  int get hashCode => hashValues(url, scale, width, height);

  @override
  String toString() => '$runtimeType("$url", scale: $scale, size: ($width,$height))';
}
