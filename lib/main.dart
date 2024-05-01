import 'package:flutter/material.dart';
import 'package:my_paint_app/all_sketch_listing.dart';

void main() {
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(useMaterial3: true),
    home: const AllSketchListing(),
  ));
}


