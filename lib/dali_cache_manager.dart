import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dali/site.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart';

final bool debug = true;

class DaliCacheManager {
  final String cacheFolder;
  static var httpClient = new HttpClient();

  DaliCacheManager(this.cacheFolder);

  static var site = new Site(new SiteSetting(4, new Duration(seconds: 10)));

  int getRoundedSize(int size) {
    if (size <= 50) {
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

  Future<File> getFile(String url, int width, int height) async {
    if (width != null) {
      width = width * ui.window.devicePixelRatio.toInt();
    }
    if (height != null) {
      height = height * ui.window.devicePixelRatio.toInt();
    }
    return downloadFile(url, width, height);
  }

  Future<File> downloadFile(String url, int width, int height) async {
    width = getRoundedSize(width);
    height = getRoundedSize(height);
    String filename = "${url.hashCode} - $width x $height";

    File file = new File('$cacheFolder/$filename');
    bool exists = await file.exists();
    bool empty = exists ? await file.length() == 0 : true;

    String filenameOrig = "${url.hashCode}";
    File fileOrig = new File('$cacheFolder/$filenameOrig');
    bool origExists = await fileOrig.exists();

    if (!origExists && !exists) {
      if (debug) print("!origExists && !exists");
      fileOrig = await downloadAndSave(url, fileOrig);
      if (width != null && height != null) {
        convertAndSaveInBackground(fileOrig, file, width, height);
      }
      if (debug) print("return fileOrig");
      return fileOrig;
    }

    if (origExists && !exists) {
      if (debug) print("origExists:OK && !exists");
      if (width != null && height != null) {
        convertAndSaveInBackground(fileOrig, file, width, height);
      }
      if (debug) print("return fileOrig");
      return fileOrig;
    }

    if (!origExists && exists) {
      if (!empty) {
        if (debug) print("!origExists && exists:OK  && !isEmpty");
        downloadAndSave(url, fileOrig);
        if (debug) print("return file");
        return file;
      } else {
        if (debug) print("!origExists && exists:OK && isEmpty");
        fileOrig = await downloadAndSave(url, fileOrig);
        if (debug) print("return fileOrig");
        return fileOrig;
      }
    }

    if (!empty) {
      if (debug) print("OK");
      if (debug) print("return file");
      return file;
    } else {
      if (debug) print("OK");
      if (debug) print("return fileOrig");
      return fileOrig;
    }
  }

  Future<File> downloadAndSaveInSite(String url, File file) async {
    File fileOut = await DaliCacheManager.site.commission(downloadAndSave, positionalArgs: [url, file]);
    return fileOut;
  }

  static Future<File> downloadAndSave(String url, File file) async {
    if (debug) print("downloadAndSave - init");
    var bytes = await download(url);
    await file.writeAsBytes(bytes);
    if (debug) print("downloadAndSave - end");
    return file;
  }

  static Future<List<int>> download(String url) async {
    if (debug) print("Downloading image: $url");
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
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
}

class CompressionResult {
  static const RESULT_OK = 0;
  static const RESULT_SAME_IMAGE = 1;
  static const RESULT_NOT_SUPPORTED = 2;
  final int result;
  final Uint8List data;

  CompressionResult(this.result, this.data);
}

Future<bool> convertAndSaveInBackground(File fileOrig, File fileDestination, int width, int height) async {
  if (debug) print("convertAndSaveInBackground - init");
  List<int> bytes = await fileOrig.readAsBytes();

  if (width != null && width > 0 && height != null && height > 0) {
    //bytes = compress(bytes, width, height);
    CompressionResult result = await DaliCacheManager.site.commission(

        /// The very, very expensive function which compresses
        /// images using a dart library
        DaliCacheManager.compress,

        /// you can specify the positional arguments here
        positionalArgs: [bytes, width, height]);
    if (result.result == CompressionResult.RESULT_OK) {
      if (debug) print("convertAndSaveInBackground - saving resized image");
      await fileDestination.writeAsBytes(result.data);
      if (debug) print("convertAndSaveInBackground - end");
      return true;
    } else if (result.result == CompressionResult.RESULT_SAME_IMAGE) {
      await fileDestination.writeAsBytes([]);
      if (debug) print("convertAndSaveInBackground - end");
      return true;
    }
  }
  if (debug) print("convertAndSaveInBackground - end");
  return false;
}
