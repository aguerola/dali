import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dali/site.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart';

class DaliCacheManager {
  static bool debug = false;
  static int workersMax = 2;
  static int workerTimeoutInSeconds = 2;

  final String cacheFolder;
  final Downloader downloader;

  DaliCacheManager({@required this.cacheFolder, @required this.downloader});

  var site = new Site(new SiteSetting(
      workersMax, new Duration(seconds: workerTimeoutInSeconds)));

  int getRoundedSize(int size) {
    if (size == null) {
      return 2000;
    } else if (size <= 50) {
      return 50;
    } else if (50 < size && size <= 400) {
      return size - size % 50;
    } else if (400 < size && size <= 1000) {
      return size - size % 100;
    } else if (1000 < size && size <= 2000) {
      return size - size % 200;
    } else {
      return 2000;
    }
  }

  Future<File> getFile(String url, int width, int height, double scale) async {
    if (width != null) {
      width = (width * scale * ui.window.devicePixelRatio).toInt();
    }
    if (height != null) {
      height = (height * scale * ui.window.devicePixelRatio).toInt();
    }
    return downloadFile(url, width, height);
  }

  Future<File> downloadFile(String url, int width, int height) async {
    width = getRoundedSize(width).toInt();
    height = getRoundedSize(height).toInt();
    String fullSizeFileName = "${url.hashCode}";
    String resizeFileName = "$fullSizeFileName - $width x $height";

    File resizedFile = new File('$cacheFolder/$resizeFileName');
    File fullSizeFile = new File('$cacheFolder/$fullSizeFileName');

    if (await resizedFile.exists()) {
      if (await resizedFile.length() == 0) {
        return fullSizeFile;
      } else {
        return resizedFile;
      }
    }

    if (await fullSizeFile.exists()) {
      if (await fullSizeFile.length() == 0) {
        throw Exception("Non supported format");
      }
      convertAndSaveInBackground(fullSizeFile, resizedFile, width, height);
      return fullSizeFile;
    }

    bool success = await downloadAndSave(url, fullSizeFile, checkFormat: true);
    if (!success) {
      throw Exception("Non supported format");
    }
    if (await fullSizeFile.exists()) {
      convertAndSaveInBackground(fullSizeFile, resizedFile, width, height);
      return fullSizeFile;
    }

    throw Exception("Error obtaining the image");
  }

  static CompressionResult compress(Uint8List data, int width, int height) {
    if (debug) print("Compressing image: $width $height");
    Image image = decodeImage(data);
    if (image == null) {
      return CompressionResult(CompressionResult.RESULT_NOT_SUPPORTED, data);
    }
    if (width < image.width && height < image.height) {
      image = copyResize(image, width);
      data = encodeJpg(image);
      return CompressionResult(CompressionResult.RESULT_OK, data);
    }
    return CompressionResult(CompressionResult.RESULT_SAME_IMAGE, data);
  }

  Future<bool> downloadAndSave(String url, File fileOrig,
      {bool checkFormat = false}) async {
    bool success = false;
    var bytes = await downloader.download(url);
    if (checkFormat && findDecoderForData(bytes) == null) {
      await fileOrig.writeAsBytes([]);
      success = false;
    } else {
      await fileOrig.writeAsBytes(bytes);
      success = true;
    }
    return success;
  }

  Future<bool> convertAndSaveInBackground(
      File fileOrig, File fileDestination, int width, int height) async {
    if (DaliCacheManager.debug) print("convertAndSaveInBackground - init");
    List<int> bytes = await fileOrig.readAsBytes();

    if (width != null && width > 0 && height != null && height > 0) {
      //bytes = compress(bytes, width, height);
      CompressionResult result = await site.commission(

          /// The very, very expensive function which compresses
          /// images using a dart library
          DaliCacheManager.compress,

          /// you can specify the positional arguments here
          positionalArgs: [bytes, width, height]);
      if (result.result == CompressionResult.RESULT_OK) {
        if (DaliCacheManager.debug)
          print("convertAndSaveInBackground - saving resized image");
        await fileDestination.writeAsBytes(result.data);
        if (DaliCacheManager.debug) print("convertAndSaveInBackground - end");
        return true;
      } else if (result.result == CompressionResult.RESULT_SAME_IMAGE) {
        await fileDestination.writeAsBytes([]);
        if (DaliCacheManager.debug) print("convertAndSaveInBackground - end");
        return true;
      }
    }
    if (DaliCacheManager.debug) print("convertAndSaveInBackground - end");
    return false;
  }
}

abstract class Downloader {
  Future<List<int>> download(String url);
}

class DownloaderImpl implements Downloader {
  static var httpClient = new HttpClient();

  @override
  Future<List<int>> download(String url) async {
    if (DaliCacheManager.debug) print("Downloading image: $url");
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  }
}

class CompressionResult {
  static const RESULT_OK = 0;
  static const RESULT_SAME_IMAGE = 1;
  static const RESULT_NOT_SUPPORTED = 2;
  final int result;
  final Uint8List data;

  CompressionResult(this.result, this.data);
}
