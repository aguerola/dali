library dali;

import 'package:dali/cached_image.dart';
import 'package:flutter/widgets.dart';

export 'package:dali/cached_image.dart';
export 'package:dali/dali_image_provider.dart';

class Dali extends StatelessWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget errorWidget;
  final BoxFit fit;

  Dali(this.imageUrl,
      {this.placeholder, this.errorWidget, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CachedImage(
          fit: fit,
          imageUrl: imageUrl,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      },
    );
  }
}
