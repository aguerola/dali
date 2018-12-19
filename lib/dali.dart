library dali;

import 'package:dali/cached_image.dart';
import 'package:flutter/widgets.dart';

export 'package:dali/cached_image.dart';
export 'package:dali/dali_cache_binding.dart';
export 'package:dali/cached_image_provider.dart';

class Dali extends StatelessWidget {
  final String imageUrl;
  final Widget placeholder;
  final Widget errorWidget;

  Dali(this.imageUrl, {this.placeholder, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CachedImage(
          fit: BoxFit.cover,
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
