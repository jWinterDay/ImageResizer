import 'package:image_resizer/models/CustomImageFormat.dart';
import 'package:image_resizer/models/LoadResult.dart';

import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;


class HomeBloc {
  static const IMG_ARR = ['assets/img/raketa.jpeg', 'assets/img/Olsen.jpg', 'assets/img/nature.jpg', ];
  static const IMG_MAX_WIDTH_PX = 1200;
  static const IMG_MAX_HEIGHT_PX = 1200;

  int _currentImgIndex = 0;

  //possible better to change int to some settings class...
  PublishSubject<int> _settingsController = PublishSubject();
  Subject<LoadResult> _imageController = new PublishSubject();

  ValueConnectableObservable<LoadResult> _lastValObservable;

  //public
  Observable<LoadResult> get resultStream => _lastValObservable;
  //LoadResult getInitData() => new LoadResult(imageFormat: CustomImageFormat.IF_16_TO_9, error: null, image: null, isLoading: false);//null;

  loadImage() { _imageController.sink.add(null); }
  changeSettings(int imageFormat) { _settingsController.sink.add(imageFormat); }

  //constructor
  HomeBloc() {
    //settings stream
     Observable<LoadResult> settingsStream = _settingsController
     .switchMap((p) { return _loadAsync(p, isNextImage: false); })
      .doOnData((d) {
        //print('[SETTINGS] data = $d');
      });

    //image stream
    Observable<LoadResult> imageStream = _imageController
      .switchMap((p) {
        return _loadAsync(null, isNextImage: true);
      })
      .doOnData((d) {
        //print('[AFTER LOAD] data = $d');
      });

    //merged
    Observable<Observable<LoadResult>> streams = Observable.merge([settingsStream, imageStream])
      .doOnData((data) {
        //print('[MERGED] data = $data');
      })
      .map((p) => Observable.just(p));

    _lastValObservable = Observable
      .switchLatest(streams)
      .doOnData((data) {
        //print('[SWITCH LATEST] data = $data');
      })
      .publishValue();

    _lastValObservable.connect();
  }

  String _getNextImgPath(bool isGenerate) {
    if (!isGenerate) return IMG_ARR[_currentImgIndex];

    if (_currentImgIndex >= IMG_ARR.length - 1) {
      _currentImgIndex = 0;
    } else {
      _currentImgIndex++;
    }

    return IMG_ARR[_currentImgIndex];
  }

  //main common calc func
  Stream<LoadResult> _loadAsync(int imageFormat, {bool isNextImage}) async* {
    final LoadResult lastVal = _lastValObservable.value;

    LoadResult nextVal = lastVal ?? new LoadResult.init();
    int nextImageFormat = imageFormat??nextVal.imageFormat;

    //
    if (lastVal?.image == null && !isNextImage) {
      yield nextVal.copyWith(imageFormat: nextImageFormat);
      return;
    }

    yield new LoadResult.loading();

    ui.Image uiImage;
    try {
      uiImage = await _loadFromSource(_getNextImgPath(isNextImage));

      if (nextImageFormat == CustomImageFormat.IF_ORIG) {
        var imageWidget = await _uiImageToWidget(uiImage);
        yield new LoadResult.completed(imageWidget, imageFormat: nextImageFormat);
        return;
      }
    } catch(ex) {
      yield new LoadResult.error(ex, imageFormat: nextImageFormat);
      return;
    }
    
    if (uiImage.width > IMG_MAX_WIDTH_PX || uiImage.height > IMG_MAX_HEIGHT_PX) {
      try {
        uiImage = await _reformatUiImage(uiImage, nextImageFormat);
      } catch(ex) {
        yield new LoadResult.error(ex, imageFormat: nextImageFormat);
        return;
      }
    }

    //convert to Image widget
    var imageWidget = await _uiImageToWidget(uiImage);
    yield new LoadResult.completed(imageWidget, imageFormat: nextImageFormat);
  }

  Future<Image> _uiImageToWidget(ui.Image uiImage) async {
    var byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();
    var imgWidget = new Image.memory(buffer);

    return imgWidget;
  }

  Future<ui.Image> _loadFromSource(String asset) async {
    var data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> _reformatUiImage(ui.Image uiImage, int imageFormatIndex) async {
    double origWidth = uiImage.width.toDouble();
    double origHeight = uiImage.height.toDouble();

    double imageFormat = CustomImageFormat.formatsValues[imageFormatIndex];
    double formattedWidth = origWidth;
    double formattedHeight = origWidth / imageFormat;

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
    if (_imageController != null) await _imageController.close();
    if (_settingsController != null) await _settingsController.close();
  }
}  