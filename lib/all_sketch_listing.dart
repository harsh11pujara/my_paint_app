import 'package:flutter/material.dart';
import 'package:my_paint_app/draw_sketch.dart';

class AllSketchListing extends StatefulWidget {
  const AllSketchListing({Key? key}) : super(key: key);

  @override
  State<AllSketchListing> createState() => _AllSketchListingState();
}

class _AllSketchListingState extends State<AllSketchListing> {
  List allSketches = [];

  @override
  void initState() {
    super.initState();
    getSketchesFromLocal();
  }

  Future<void> getSketchesFromLocal() async {
    // Fetching sketch data from local DB
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
                return Container();
              },
            )
          : const Center(
              child: Text("Draw Some Sketches", style: TextStyle(height: 22, fontStyle: FontStyle.italic)),
            ),
    );
  }
}
