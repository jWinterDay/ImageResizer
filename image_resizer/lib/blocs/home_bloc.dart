import 'package:image_resizer/models/LoadResult.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;


class HomeBloc {
  //static const IMG_PATH = 'assets/img/sabaton.jpg';
  static const IMG_PATH = 'assets/img/Olsen.jpg';
  static const IMG_MAX_WIDTH_PX = 1200;
  static const IMG_FORMAT_RATIO = 16/9;
  static const IMG_MAX_HEIGHT_PX = 1200;



  PublishSubject<LoadResult> _imageController;

  //StreamSink<LoadResult> get inSink => _imageController.sink;
  Observable<LoadResult> get imageStream => _imageController.stream;

  //constructor
  HomeBloc() {
    _imageController = new PublishSubject();

    _imageController.stream
      //.map((p) => true)
      //.doOnData((data) {
        //print('[BEFORE LOAD] data: $data');
      //})
      //.flatMap(_load)
      .listen((data) {
        //print('[RESULT DATA] = $data');
      });
  }

  LoadResult getInitData() {
    return null;
  }

  loadImage() async {
    //sink
    _imageController.sink.add(new LoadResult.loading());

    await Future.delayed(Duration(seconds: 5));

    var uiImage;
    try {
      uiImage = await _load(IMG_PATH);
    } catch(ex) {
      _imageController.sink.add(new LoadResult.error(ex));
      return;
    }
    
    if (uiImage.width > IMG_MAX_WIDTH_PX || uiImage.height > IMG_MAX_HEIGHT_PX) {
      try {
        uiImage = await recalcUiImage(uiImage);
      } catch(ex) {
        _imageController.sink.add(new LoadResult.error(ex));
        return;
      }
    }

    var byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();

    var imgWidget = Image.memory(buffer);

    //sink
    _imageController.sink.add(new LoadResult.completed(imgWidget));
  }

  Future<ui.Image> recalcUiImage(ui.Image uiImage) async {
    ui.Image resizedImage = uiImage;
    print('original img w: ${resizedImage.width}, h: ${resizedImage.height}');

    if (uiImage.width > IMG_MAX_WIDTH_PX || uiImage.height > IMG_MAX_HEIGHT_PX) {
      resizedImage = await _resizeUiImage(uiImage);
    }
    ui.Image reformattedImage = await _reformatUiImage(resizedImage);

    return reformattedImage;
  }

  Future<ui.Image> _resizeUiImage(ui.Image uiImage) async {
    double origWidth = uiImage.width.toDouble();
    double origHeight = uiImage.height.toDouble();

    if (origWidth < IMG_MAX_WIDTH_PX && origHeight < IMG_MAX_HEIGHT_PX) {
      return uiImage;
    }

    double ratioX = IMG_MAX_WIDTH_PX / origWidth;
    double ratioY = IMG_MAX_HEIGHT_PX / origHeight;
    double ratio = math.min(ratioX, ratioY);

    double nextWidth = origWidth * ratio;
    double nextHeight = origHeight * ratio;

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(nextWidth.toDouble(), nextHeight.toDouble())));
    Paint paint = Paint();

    Rect src = Rect.fromLTWH(0.0, 0, origWidth, origHeight);
    Rect dst = Rect.fromLTWH(0.0, 0.0, nextWidth, nextHeight);
    canvas.drawImageRect(uiImage, src, dst, paint);

    ui.Picture pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(nextWidth.round(), nextHeight.round());

    print('resized img w: ${img.width}, h: ${img.height}');

    return img;
  }

  Future<ui.Image> _reformatUiImage(ui.Image uiImage) async {
    double origWidth = uiImage.width.toDouble();
    double origHeight = uiImage.height.toDouble();

    double formattedWidth = origWidth;
    double formattedHeight = origWidth / IMG_FORMAT_RATIO;

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(formattedWidth, origHeight)));
    Paint paint = Paint();

    Rect src = Rect.fromLTWH(0.0, (origHeight - formattedHeight)/2, formattedWidth, formattedHeight);
    Rect dst = Rect.fromLTWH(0.0, 0.0, formattedWidth, formattedHeight);

    canvas.drawImageRect(uiImage, src, dst, paint);

    ui.Picture pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(formattedWidth.round(), formattedHeight.round());

    print('result format img w: ${img.width}, h: ${img.height}');

    return img;
  }


  Future<ui.Image> _load(String asset) async {
    var data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  dispose() async {
    await _imageController.close();
  }
}

  /*Stream<LoadResult> _load(bool isInit) async* {
    yield new LoadResult.loading();

    await Future.delayed(Duration(seconds: 1));

    //
    var img = Image(
      fit: BoxFit.contain,
      image: AssetImage('assets/img/sabaton.jpg'),
    );

    LoadResult result = new LoadResult(error: null, image: img, isLoading: false, );

    //print('-------------- res = $result');

    yield result;
  }*/