import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_resizer/models/CustomImageFormat.dart';


class LoadResult {
  bool isLoading;
  Object error;
  Image image;
  int imageFormat;

  LoadResult({
    this.isLoading,
    this.error,
    this.image,
    this.imageFormat,
  });

  factory LoadResult.init() =>
    LoadResult(
      error: null,
      isLoading: false,
      image: null,
      imageFormat: CustomImageFormat.IF_16_TO_9,
    );

  factory LoadResult.loading() =>
    LoadResult(
      error: null,
      isLoading: true,
      image: null,
      imageFormat: null,
    );

  factory LoadResult.completed(Image image, {int imageFormat = CustomImageFormat.IF_16_TO_9}) =>
    LoadResult(
      error: null,
      isLoading: false,
      image: image,
      imageFormat: imageFormat,
    );

  factory LoadResult.error(Object error, {int imageFormat = CustomImageFormat.IF_16_TO_9}) =>
    LoadResult(
      error: error,
      isLoading: false,
      image: null,
      imageFormat: imageFormat,
    );

  LoadResult copyWith({
    bool isLoading,
    Object error,
    Image image,
    int imageFormat,
  }) =>
    LoadResult(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      image: image ?? this.image,
      imageFormat: imageFormat ?? this.imageFormat,
    );


  factory LoadResult.fromRawJson(String str) => LoadResult.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoadResult.fromJson(Map<String, dynamic> json) => new LoadResult(
    isLoading: json["is_loading"],
    error: json["error"],
    image: json["image"],
    imageFormat: json["image_format"],
  );

  Map<String, dynamic> toJson() => {
    "is_loading": isLoading,
    "error": error,
    "image": image,
    "image_format": imageFormat,
  };

  @override
  String toString() => 'isLoading: $isLoading, error: $error, image: $image, imageFormat: $imageFormat';
}