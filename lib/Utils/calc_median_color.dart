// import 'dart:io';
import 'dart:math' as math;

// import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';

Future<List<Color>> getMedianColor(url) async {
  // img.Image? bitmap =
  //     img.decodeImage(new File('assets/images/keyboard.jpg').readAsBytesSync());
  var bytesOri = (await NetworkAssetBundle(Uri.parse(url)).load(url));
  var bytes = bytesOri.buffer.asUint8List();
  img.Image? bitmap = img.decodeImage(bytes);
  // Bitmap bitmap = await Bitmap.fromProvider(NetworkImage(url));

  int redBucket = 0;
  int greenBucket = 0;
  int blueBucket = 0;
  int pixelCount = 0;

  for (int y = 0; y < bitmap!.height; y++) {
    for (int x = 0; x < bitmap.width; x++) {
      int c = bitmap.getPixel(x, y);

      pixelCount++;
      redBucket += img.getRed(c);
      greenBucket += img.getGreen(c);
      blueBucket += img.getBlue(c);
    }
  }
  var encodeImg =
      EncodedImage(bytesOri, width: bitmap.width, height: bitmap.height);
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(MemoryImage(bytes));

  List<Color> myColor = [];

  Color averageColor = Color.fromRGBO(redBucket ~/ pixelCount,
      greenBucket ~/ pixelCount, blueBucket ~/ pixelCount, 1);

  myColor.add(averageColor);
  myColor.add(paletteGenerator
      .paletteColors[paletteGenerator.paletteColors.length ~/ 2 + 1].color);
  // .paletteColors[paletteGenerator.paletteColors.length - 1]
  // .color);
  return myColor;
}

Future<Color> getImagePalette(ImageProvider imageProvider) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(imageProvider);
  return paletteGenerator.dominantColor!.color;
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

bool isLightColor(Color color) {
  final hsp = math.sqrt(0.299 * (color.red * color.red) +
      0.587 * (color.green * color.green) +
      0.114 * (color.blue * color.blue));
  if (hsp > 127.5) {
    return true;
  } else {
    return false;
  }
}

// Color getSimilarColor(Color color) {
//   final similars = [Colors.]
//   final hsl = HSLColor.fromColor(color);
// }
