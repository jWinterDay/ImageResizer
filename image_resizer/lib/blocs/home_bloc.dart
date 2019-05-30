import 'package:image_resizer/models/LoadResult.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;


class HomeBloc {
  static const IMG_ARR = ['assets/img/sabaton.jpg', 'assets/img/Olsen.jpg', 'assets/img/raketa.jpeg'];
  //static const IMG_PATH = 'assets/img/sabaton.jpg';
  //static const IMG_PATH = 'assets/img/Olsen.jpg';
  static const IMG_PATH = 'assets/img/raketa.jpeg';
  static const IMG_MAX_WIDTH_PX = 1200;
  static const IMG_FORMAT_RATIO = 16/9;
  static const IMG_MAX_HEIGHT_PX = 1200;

  int _currentImgIndex = 0;


  PublishSubject<LoadResult> _imageController = new PublishSubject();

  //public
  Observable<LoadResult> imageStream;// => _imageController.stream;
  LoadResult getInitData() => null;
  loadImage() { _imageController.sink.add(null); }

  //constructor
  HomeBloc() {
    imageStream = _imageController
      .switchMap((p) {
        return _loadAsync(true);
      })
      .doOnData((d) {
        //print('[AFTER LOAD] data = $d');
      });
  }

  String _getNextImgPath() {
    if (_currentImgIndex >= IMG_ARR.length - 1) {
      _currentImgIndex = 0;
    } else {
      _currentImgIndex++;
    }

    return IMG_ARR[_currentImgIndex];
  }

  Stream<LoadResult> _loadAsync(bool isInit) async* {
    yield new LoadResult.loading();

    //await Future.delayed(Duration(seconds: 5));

    ui.Image uiImage;
    try {
      uiImage = await _loadFromSource(_getNextImgPath());//IMG_PATH);
    } catch(ex) {
      yield new LoadResult.error(ex);
      return;
    }
    
    if (uiImage.width > IMG_MAX_WIDTH_PX || uiImage.height > IMG_MAX_HEIGHT_PX) {
      try {
        uiImage = await _reformatUiImage(uiImage);
      } catch(ex) {
        yield new LoadResult.error(ex);
        return;
      }
    }

    //convert to Image widget
    var byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();
    var imgWidget = new Image.memory(buffer);

    yield new LoadResult.completed(imgWidget);
  }

  Future<ui.Image> _loadFromSource(String asset) async {
    var data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> _reformatUiImage(ui.Image uiImage) async {
    double origWidth = uiImage.width.toDouble();
    double origHeight = uiImage.height.toDouble();

    double formattedWidth = origWidth;
    double formattedHeight = origWidth / IMG_FORMAT_RATIO;

    double nextWidth = formattedWidth;
    double nextHeight = formattedHeight;
    if (origWidth > IMG_MAX_WIDTH_PX || origHeight > IMG_MAX_HEIGHT_PX) {
      double ratioX = IMG_MAX_WIDTH_PX / formattedWidth;
      double ratioY = IMG_MAX_HEIGHT_PX / formattedHeight;
      double ratio = math.min(ratioX, ratioY);

      nextWidth = formattedWidth * ratio;
      nextHeight = formattedHeight * ratio;
    }

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(formattedWidth, origHeight)));
    Paint paint = Paint();

    Rect src = Rect.fromLTWH(0.0, (origHeight - formattedHeight)/2, formattedWidth, formattedHeight);
    Rect dst = Rect.fromLTWH(0.0, 0.0, nextWidth, nextHeight);
    canvas.drawImageRect(uiImage, src, dst, paint);

    ui.Picture pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(nextWidth.round(), nextHeight.round());

    print('result format img w: ${img.width}, h: ${img.height}');

    return img;
  }

  dispose() async {
    await _imageController.close();
  }
}  