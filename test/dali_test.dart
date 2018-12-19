import 'dart:io';

import 'package:dali/dali_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {


  test('resize to smaller image', () async {
    File orig = File("test_images/plain_512_512.png");
    File dest = File("temporary_directory/plain_100_100.png");
    await delete(dest);
    await convertAndSaveInBackground(orig, dest, 100, 100);

    expect(await dest.exists(), true);

    await delete(dest);
  });
  test('resize to smaller image 2', () async {
    File orig = File("test_images/plain_512_512.png");
    File dest = File("temporary_directory/plain_100_100.png");
    await delete(dest);
    await convertAndSaveInBackground(orig, dest, 95, 60);

    expect(await dest.exists(), true);

    //await delete(dest);
  });

  test('resize unsupported image', () async {
    File orig = File("test_images/sails.bmp");
    File dest = File("temporary_directory/sails_100_100.png");
    await delete(dest);
    await convertAndSaveInBackground(orig, dest, 100, 100);

    //expect(await dest.exists(), true);

    //await delete(dest);
  });

  test('resize to bigger image creates an empty file', () async {
    File orig = File("test_images/plain_512_512.png");
    File dest = File("temporary_directory/plain_1000_1000.png");
    await delete(dest);
    await convertAndSaveInBackground(orig, dest, 1000, 1000);

    expect(await dest.exists(), true);
    expect(await dest.length(), 0);
    await dest.delete();
  });

  test('download image', () async {
    var cacheManager = new DaliCacheManager("temporary_directory");
    var file = File('temporary_directory/315137417');
    var file400 = File('temporary_directory/315137417 - 400 x 400');

    await delete(file);
    await delete(file400);

    expect(await file.exists(), false);
    expect(await file400.exists(), false);

    await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 400, 400);
    await Future.delayed(const Duration(seconds: 1), () => "1");

    expect(await file.exists(), true);
    expect(await file400.exists(), true);

    await delete(file);
    await delete(file400);
  });

  test('testing similar sizes', () async {
    var cacheManager = new DaliCacheManager("temporary_directory");

    var file = File('temporary_directory/315137417');
    var file400 = File('temporary_directory/315137417 - 400 x 400');

    await delete(file);
    await delete(file400);

    await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 400, 400);
    await Future.delayed(const Duration(seconds: 1), () => "1");
    var downloadedFile =
        await cacheManager.downloadFile("https://homepages.cae.wisc.edu/~ece533/images/airplane.png", 410, 410);
    await Future.delayed(const Duration(seconds: 1), () => "1");

    expect(downloadedFile.path, file400.path);

    await delete(file);
    await delete(file400);
  });



  test('trying to download a image and resize to a bigger one gives the original', () async {
    var file = File('temporary_directory/315137417');
    var file400 = File('temporary_directory/315137417 - 400 x 400');
    var file1000 = File('temporary_directory/315137417 - 1000 x 1000');
    await delete(file);
    await delete(file400);
    await delete(file1000);
    var cacheManager = new DaliCacheManager("temporary_directory");
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

    await delete(file);
    await delete(file400);
    await delete(file1000);
  });
}

Future<void> delete(File file) async {
  if (await file.exists()) {
    await file.delete();
  }
}
