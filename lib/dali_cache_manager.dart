import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dali/site.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';


final bool debug = false;

class DaliCacheManager {
  static var httpClient = new HttpClient();
  var lock = new Object();

  Future<File> getFile(String url, int width, int height) async {
    return downloadFile(url, width, height);
  }

  static var site = new Site(new SiteSetting(4, new Duration(seconds: 10)));

  Future<File> downloadFile(String url, int width, int height) async {
    if (width != null) {
      width = width * ui.window.devicePixelRatio.toInt();
    }
    if (height != null) {
      height = height * ui.window.devicePixelRatio.toInt();
    }

    String filename = "${url.hashCode} - $width x $height";
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/$filename');
    bool exists = await file.exists();

    String filenameOrig = "${url.hashCode}";
    File fileOrig = new File('$dir/$filenameOrig');
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
      if (debug) print("!origExists && exists:OK");
      downloadAndSave(url, fileOrig);
      if (debug) print("return file");
      return file;
    }

    if (debug) print("OK");
    if (debug) print("return file");
    return file;
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

  static Uint8List compress(Uint8List data, int width, int height) {
    if (debug) print("Compressing image: $width $height");
    Image image = decodeImage(data);
    image = copyResize(image, width);
    data = encodeJpg(image);
    return data;
  }
}

void convertAndSaveInBackground(File fileOrig, File fileDestination, int width, int height) async {
  if (debug) print("convertAndSaveInBackground - init");
  List<int> bytes = await fileOrig.readAsBytes();
  if (width != null && width > 0 && height != null && height > 0) {
    //bytes = compress(bytes, width, height);
    bytes = await DaliCacheManager.site.commission(

        /// The very, very expensive function which compresses
        /// images using a dart library
        DaliCacheManager.compress,

        /// you can specify the positional arguments here
        positionalArgs: [bytes, width, height]);
  }
  await fileDestination.writeAsBytes(bytes);
  if (debug) print("convertAndSaveInBackground - end");
}
