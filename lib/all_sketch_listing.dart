import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_paint_app/draw_sketch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllSketchListing extends StatefulWidget {
  const AllSketchListing({Key? key}) : super(key: key);

  @override
  State<AllSketchListing> createState() => _AllSketchListingState();
}

List<Map<String, String>> allSketches = [];

class _AllSketchListingState extends State<AllSketchListing> {

  @override
  void initState() {
    super.initState();
    getSketchesFromLocal();
  }

  Future<void> getSketchesFromLocal() async {
    // Fetching sketch data from local DB
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localData = prefs.getStringList("allSketch");
    debugPrint(localData.toString());
    if (localData != null && localData.isNotEmpty) {
      allSketches = localData.map((e) => jsonDecode(e) as Map<String, String>).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("All Sketches"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrawSketch(),
                ));
          },
          child: const Icon(Icons.format_paint_sharp)),
      body: allSketches.isNotEmpty
          ? ListView.builder(
              itemCount: allSketches.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrawSketch(title: allSketches[index].keys.toList()[0], sketchData: allSketches[index].values.toList()[0]),
                        ));
                  },
                  title: Text(allSketches[index].keys.toList()[0]),

                );
              },
            )
          : const Center(
              child: Text("Draw Some Sketches", style: TextStyle(height: 22, fontStyle: FontStyle.italic)),
            ),
    );
  }
}
