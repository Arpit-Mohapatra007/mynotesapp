import 'package:flutter/material.dart' show immutable;

typedef ClosedLoadingScreen = bool Function();
typedef UpdateLoadingScreeen = bool Function(String text);

@immutable
class LoadingScreenController {
  final ClosedLoadingScreen close;
  final UpdateLoadingScreeen update;

  const LoadingScreenController({required this.close, required this.update});
  
}