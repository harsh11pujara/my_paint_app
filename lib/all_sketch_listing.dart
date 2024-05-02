import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_paint_app/draw_sketch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllSketchListing extends StatefulWidget {
  const AllSketchListing({Key? key}) : super(key: key);

  @override
  State<AllSketchListing> createState() => _AllSketchListingState();
}

List<Map<String, dynamic>> allSketches = [];

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
    // debugPrint(localData.toString());
    if (localData != null && localData.isNotEmpty) {
      allSketches = localData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Sketches",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            linesMap.clear();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrawSketch(),
                )).then((value) async {
              await getSketchesFromLocal();
            });
          },
          backgroundColor: Colors.purple[100],
          child: const Icon(
            Icons.format_paint_sharp,
            color: Colors.black54,
          )),
      body: allSketches.isNotEmpty
          ? ListView.builder(
              itemCount: allSketches.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrawSketch(
                              title: allSketches[index].keys.toList()[0], sketchData: allSketches[index].values.toList()[0]),
                        )).then((value) async {
                      await getSketchesFromLocal();
                    });
                  },
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        boxShadow: [
                          BoxShadow(color: Colors.purple[100]!, blurRadius: 5, offset: Offset(5,5))
                        ]
                      ),
                      child: Text(
                        allSketches[index].keys.toList()[0],
                        style: const TextStyle(fontSize: 16),
                      )),
                );
              },
            )
          : const Center(
              child: Text("Draw Some Sketches", style: TextStyle(height: 22, fontStyle: FontStyle.italic)),
            ),
    );
  }
}
