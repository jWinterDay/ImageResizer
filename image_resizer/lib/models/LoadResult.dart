import 'dart:convert';
import 'package:flutter/material.dart';


class LoadResult {
  bool isLoading;
  Object error;
  Image image;

  LoadResult({
    this.isLoading,
    this.error,
    this.image,
  });

  factory LoadResult.loading() =>
    LoadResult(
      error: null,
      isLoading: true,
      image: null,
    );

  factory LoadResult.completed(Image image) =>
    LoadResult(
      error: null,
      isLoading: false,
      image: image,
    );

  factory LoadResult.error(Object error) =>
    LoadResult(
      error: error,
      isLoading: false,
      image: null,
    );

  factory LoadResult.fromRawJson(String str) => LoadResult.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoadResult.fromJson(Map<String, dynamic> json) => new LoadResult(
    isLoading: json["is_loading"],
    error: json["error"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "is_loading": isLoading,
    "error": error,
    "image": image,
  };

  @override
  String toString() => 'isLoading: $isLoading, error: $error, image: $image';
}