import 'dart:io';

import 'package:dali/cached_image_provider.dart';
import 'package:dali/dali_cache_manager.dart';
import 'package:dali/site.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resize to smaller image', () async {
    File orig = File("test_images/plain_512_512.png");
    File dest = File("temporary_directory/plain_100_100.png");
    deleteTempFolder();
    await convertAndSaveInBackground(orig, dest, 100, 100);

    expect(await dest.exists(), true);

    deleteTempFolder();
  });
  test('resize to smaller image 2', () async {
    File orig = File("test_images/plain_512_512.png");
    File dest = File("temporary_directory/plain_95_60.png");
    deleteTempFolder();
    await convertAndSaveInBackground(orig, dest, 95, 60);

    expect(await dest.exists(), true);

    deleteTempFolder();
  });

  test('resize unsupported image', () async {
    File orig = File("test_images/sails.bmp");
    File dest = File("temporary_directory/sails_100_100.png");
    deleteTempFolder();
    await convertAndSaveInBackground(orig, dest, 100, 100);

    //expect(await dest.exists(), true);

    //await delete(dest);
    deleteTempFolder();
  });

  test('resize to bigger image creates an empty file', () async {
    File orig = File("test_images/plain_512_512.png");
    File dest = File("temporary_directory/plain_1000_1000.png");
    deleteTempFolder();
    await convertAndSaveInBackground(orig, dest, 1000, 1000);

    expect(await dest.exists(), true);
    expect(await dest.length(), 0);
    deleteTempFolder();
  });

  test('download image', () async {
    var cacheManager = new DaliCacheManager(
      cacheFolder: "temporary_directory",
      downloader: DownloaderImpl(),
    );
    var file = File('temporary_directory/315137417');
    var file400 = File('temporary_directory/315137417 - 400 x 400');

    deleteTempFolder();

    expect(await file.exists(), false);
    expect(await file400.exists(), false);

    await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 400, 400);
    await Future.delayed(const Duration(seconds: 1), () => "1");

    expect(await file.exists(), true);
    expect(await file400.exists(), true);

    deleteTempFolder();
  });

  test('testing similar sizes', () async {
    var cacheManager = new DaliCacheManager(
      cacheFolder: "temporary_directory",
      downloader: DownloaderImpl(),
    );

    var file400 = File('temporary_directory/315137417 - 400 x 400');

    deleteTempFolder();

    await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 400, 400);
    await Future.delayed(const Duration(seconds: 1), () => "1");
    var downloadedFile =
        await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 410, 410);
    await Future.delayed(const Duration(seconds: 1), () => "1");

    expect(downloadedFile.path, file400.path);

    deleteTempFolder();
  });

  test('trying to download a image and resize to a bigger one gives the original', () async {
    deleteTempFolder();
    var file = File('temporary_directory/315137417');
    var file400 = File('temporary_directory/315137417 - 400 x 400');
    var file1000 = File('temporary_directory/315137417 - 1000 x 1000');
    var cacheManager = new DaliCacheManager(
      cacheFolder: "temporary_directory",
      downloader: DownloaderImpl(),
    );
    File downloadedFile =
        await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 1000, 1000);
    await Future.delayed(const Duration(seconds: 2), () => "1");

    expect(await file.exists(), true, reason: "Checks if the original file was downloaded");
    expect(await file1000.length(), 0, reason: "Resized file should be empty");
    expect(await downloadedFile.length() > 0, true, reason: "Returned file should not be empty");
    expect(downloadedFile.path, file.path, reason: "Returned file should be the original");

    File downloadedFile2 =
        await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 1000, 1000);
    await Future.delayed(const Duration(seconds: 2), () => "1");
    expect(await downloadedFile2.length() > 0, true, reason: "Returned file should not be empty");
    expect(downloadedFile2.path, file.path, reason: "Returned file should be the original");

    File downloadedFile3 =
        await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 400, 400);
    await Future.delayed(const Duration(seconds: 2), () => "1");
    expect(downloadedFile3.path, file.path, reason: "Returned file should be the original");
    expect(await file400.exists(), true, reason: "Resized file should exist");

    File downloadedFile4 =
        await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 400, 400);
    await Future.delayed(const Duration(seconds: 2), () => "1");
    expect(downloadedFile4.path, file400.path, reason: "Returned file should be the resized version");

    deleteTempFolder();
  });

  test('download null size downloads 2000x2000', () async {
    deleteTempFolder();
    var cacheManager = new DaliCacheManager(
      cacheFolder: "temporary_directory",
      downloader: DownloaderImpl(),
    );
    var file = File('temporary_directory/315137417');
    var resizedEmpty = File('temporary_directory/315137417 - 2000 x 2000');

    await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", null, null);
    await Future.delayed(const Duration(seconds: 1), () => "1");

    expect(await file.exists(), true);
    expect(await resizedEmpty.exists(), true);

    deleteTempFolder();
  });

  test('download unsupported image', () async {
    var cacheManager = new DaliCacheManager(
      cacheFolder: "temporary_directory",
      downloader: DownloaderImpl(),
    );

    deleteTempFolder();

    bool didThrowException = false;
    try {
      await cacheManager.downloadFile('https://homepages.cae.wisc.edu/~ece533/images/barbara.bmp', null, null);
      await Future.delayed(const Duration(seconds: 1), () => "1");
    } catch (e) {
      didThrowException = true;
    }

    expect(didThrowException, true);
    deleteTempFolder();
  });
}

DaliCacheManager daliCacheManager() {
  DaliCacheManager.debug = true;
  DaliImageProvider.debug = true;
  Site.debug = true;
  var cacheManager = new DaliCacheManager(
    cacheFolder: "temporary_directory",
    downloader: DownloaderImpl(),
  );
  return cacheManager;
}

void deleteTempFolder() {
  Directory d = Directory("temporary_directory");
  if (!d.existsSync()) {
    d.createSync();
  }
  d.listSync().forEach((f) => f.deleteSync());
}
