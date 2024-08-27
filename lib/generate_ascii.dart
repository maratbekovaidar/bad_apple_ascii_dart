import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:opencv_dart/opencv_dart.dart';

const List<String> asciiChars = [
  r'$',
  '@',
  'B',
  '%',
  '8',
  '&',
  'W',
  'M',
  '#',
  '*',
  'o',
  'a',
  'h',
  'k',
  'b',
  'd',
  'p',
  'q',
  'w',
  'm',
  'Z',
  'O',
  '0',
  'Q',
  'L',
  'C',
  'J',
  'U',
  'Y',
  'X',
  'z',
  'c',
  'v',
  'u',
  'n',
  'x',
  'r',
  'j',
  'f',
  't',
  '/',
  r'|',
  '(',
  ')',
  '1',
  '{',
  '}',
  '[',
  ']',
  '?',
  '-',
  '_',
  '+',
  '~',
  '<',
  '>',
  'i',
  '!',
  'l',
  'I',
  ';',
  ':',
  ',',
  '"',
  '^',
  '`',
  '\'',
  '.',
  ' '
];

const int videoLength = 218;

img.Image scaleImage(img.Image image, {int newWidth = 100, int newHeight = 30}) {
  final originalWidth = image.width;
  final originalHeight = image.height;
  final aspectRatio = originalHeight / originalWidth.toDouble();

  if (newHeight == 0) {
    newHeight = (aspectRatio * newWidth).toInt();
  }

  return img.copyResize(image, width: newWidth, height: newHeight);
}

img.Image convertToGrayscale(img.Image image) {
  return img.grayscale(image);
}

String mapPixelsToAsciiChars(img.Image image, {double rangeWidth = 3.69}) {
  final pixels = image.data;
  final buffer = StringBuffer();

  for (final pixel in pixels!) {
    final grayValue = pixel.r;
    final charIndex = (grayValue / rangeWidth).floor();
    buffer.write(asciiChars[charIndex]);
  }

  return buffer.toString();
}

String convertImageToAscii(img.Image image, {int newWidth = 100, int newHeight = 30}) {
  image = scaleImage(image, newWidth: newWidth, newHeight: newHeight);
  image = convertToGrayscale(image);

  final asciiArt = StringBuffer();
  final asciiStr = mapPixelsToAsciiChars(image);
  for (var i = 0; i < asciiStr.length; i += newWidth) {
    asciiArt.writeln(asciiStr.substring(i, i + newWidth));
  }

  return asciiArt.toString();
}

String handleImageConversion(String imageFilePath) {
  img.Image image;

  try {
    image = img.decodeImage(File(imageFilePath).readAsBytesSync())!;
  } catch (e) {
    print('Unable to open image file $imageFilePath.');
    print(e);
    return '';
  }

  return convertImageToAscii(image);
}

void main(List<String> params) async {
  final videoCapture = VideoCapture.fromFile('video.mp4');
  int timeCount = 0;
  final List<String> frames = [];
  Mat frame = Mat.empty();

  while (timeCount <= videoLength * 1000) {
    print('Generating ASCII frame at $timeCount');

    videoCapture.set(CAP_PROP_POS_MSEC, timeCount.toDouble());
    videoCapture.read(m: frame);
    if (frame.isEmpty) break;

    final grayFrame = Mat.empty();
    cvtColor(
      frame,
      COLOR_BGR2GRAY,
      dst: grayFrame,
    );

    final image = img.decodeImage(Uint8List.fromList(grayFrame.data))!;
    File('output.jpg').writeAsBytesSync(img.encodeJpg(image));

    frames.add(handleImageConversion('output.jpg'));

    timeCount += 100;
  }

  File('play.txt').writeAsStringSync(frames.join('SPLIT'));
}