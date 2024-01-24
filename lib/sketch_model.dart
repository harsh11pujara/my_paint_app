import 'package:flutter/material.dart';

class SketchModel{
  List<Offset>? offsetList;
  final int id;
  final Color color;
  final double strokeWidth;

  SketchModel({required this.id, required this.color, required this.strokeWidth, this.offsetList = const []});
}