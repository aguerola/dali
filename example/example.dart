import 'package:dali/dali.dart';
import 'package:flutter/material.dart';


const images = [
  'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
  'https://homepages.cae.wisc.edu/~ece533/images/arctichare.png',
  'https://homepages.cae.wisc.edu/~ece533/images/baboon.png',
  'https://homepages.cae.wisc.edu/~ece533/images/barbara.bmp',
  'https://homepages.cae.wisc.edu/~ece533/images/barbara.png',
  'https://homepages.cae.wisc.edu/~ece533/images/boat.png',
  'https://homepages.cae.wisc.edu/~ece533/images/cameraman.tif',
  'https://homepages.cae.wisc.edu/~ece533/images/cat.png',
  'https://homepages.cae.wisc.edu/~ece533/images/fruits.png',
  'https://homepages.cae.wisc.edu/~ece533/images/frymire.png',
  'https://homepages.cae.wisc.edu/~ece533/images/girl.png',
  'https://homepages.cae.wisc.edu/~ece533/images/goldhill.png',
  'https://homepages.cae.wisc.edu/~ece533/images/lena.png',
  'https://homepages.cae.wisc.edu/~ece533/images/monarch.png',
  'https://homepages.cae.wisc.edu/~ece533/images/mountain.png',
  'https://homepages.cae.wisc.edu/~ece533/images/peppers.png',
  'https://homepages.cae.wisc.edu/~ece533/images/pool.png',
  'https://homepages.cae.wisc.edu/~ece533/images/sails.bmp',
  'https://homepages.cae.wisc.edu/~ece533/images/serrano.png',
  'https://homepages.cae.wisc.edu/~ece533/images/tulips.png',
  'https://homepages.cae.wisc.edu/~ece533/images/watch.png',
  'https://homepages.cae.wisc.edu/~ece533/images/zelda.png',
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Dali Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                height: 200,
                child: Dali(
                  images[index],
                  placeholder: Icon(Icons.timer),
                  errorWidget: Icon(Icons.error),
                ),
              );
            }),
      ),
    );
  }
}
