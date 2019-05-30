import 'dart:convert';
import 'package:flutter/material.dart';


class LoadResult {
  bool isLoading;
  Object error;
  Image image;
  String path;

  LoadResult({
    this.isLoading,
    this.error,
    this.image,
    this.path,
  });

  factory LoadResult.loading() =>
    LoadResult(
      error: null,
      isLoading: true,
      image: null,
      path: null,
    );

  factory LoadResult.completed(Image image) =>
    LoadResult(
      error: null,
      isLoading: false,
      image: image,
      path: null,
    );

  factory LoadResult.error(Object error) =>
    LoadResult(
      error: error,
      isLoading: false,
      image: null,
      path: null,
    );

  factory LoadResult.fromRawJson(String str) => LoadResult.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoadResult.fromJson(Map<String, dynamic> json) => new LoadResult(
    isLoading: json["is_loading"],
    error: json["error"],
    image: json["image"],
    path: json["path"],
  );

  Map<String, dynamic> toJson() => {
    "is_loading": isLoading,
    "error": error,
    "image": image,
    "path": path,
  };

  @override
  String toString() => 'isLoading: $isLoading, error: $error, image: $image, path: $path';
}