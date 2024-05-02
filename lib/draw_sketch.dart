import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_paint_app/all_sketch_listing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<int, List<Offset>?> linesMap = {};

class DrawSketch extends StatefulWidget {
  const DrawSketch({Key? key, this.title, this.sketchData}) : super(key: key);
  final String? title;
  final String? sketchData;

  @override
  State<DrawSketch> createState() => _DrawSketchState();
}

class _DrawSketchState extends State<DrawSketch> {
  int id = 0;
  List<Offset> line = [];
  double strokeWidth = 1;
  Color strokeColor = Colors.black;
  TextEditingController sketchTitle = TextEditingController();

  Future<void> saveSketchToLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = 0;
    bool containsThisSketch = allSketches.any((element) {
      if(element.keys.contains(sketchTitle.text)){
        return true;
      } else {
        return false;
      }
    });

    if(containsThisSketch) {
      index = allSketches.indexWhere((element) => element.keys.contains(sketchTitle.text));
      allSketches[index] = {sketchTitle.text.toString() : convertOffsetDataToString(linesMap)};
    } else {
      allSketches.add({sketchTitle.text.toString() : convertOffsetDataToString(linesMap)});
    }


    await prefs.setStringList("allSketch", allSketches.map((e) => jsonEncode(e)).toList());
  }

  String convertOffsetDataToString(Map<int, List<Offset>?> data) {
    Map<String, List<String>?> convertData = {};
    for(MapEntry<int, List<Offset>?> entries in data.entries){
      convertData[entries.key.toString()] = entries.value?.map((offset) => '${offset.dx},${offset.dy}').toList();
    }
    // debugPrint(convertData.toString());
    return convertData.toString();
  }

  convertStringToLineOffset(String lineOffset) {
    List<String> tempList = widget.sketchData!.split("],");
    List<String> elementList = [];

    //* Get each element of line in list form
    for (String element in tempList) {
      // debugPrint("start $element");
      String tempString = element;
      if(tempString.contains("{")) {
        tempString = tempString.replaceAll("{", "");
      }
      if(tempString.contains("}")) {
        tempString = tempString.replaceAll("}", "");
      }
      tempString = "$tempString]";
      // debugPrint("end $tempString");
      elementList.add(tempString);
    }
    // debugPrint(elementList.toString());
    //* ends


    //* assigning offset to lineMap and showing on canvas
    for(String offsets in elementList){
      int key = int.parse(offsets.split(":").first.toString().trim());
      List<String> offsetList = offsets.split(":")[1].toString().trim().replaceAll('[', '')
          .replaceAll(']', '').split(", ").toList();
      linesMap[key] = offsetList.map((e) {
        return Offset(double.parse(e.split(',')[0].toString()), double.parse(e.split(',')[1].toString()));
      }).toList();
    }
    //* ends

    id = linesMap.length;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    sketchTitle.text = widget.title ?? "Untitled ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year.toString().substring(2)} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    widget.sketchData != null ? convertStringToLineOffset(widget.sketchData!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 30,
        automaticallyImplyLeading: true,
        title: TextField(
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          controller: sketchTitle,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))
          ),
        ),
        actions: [
          TextButton(onPressed: () async {
            // save sketch to local
            if (linesMap.isNotEmpty) {
              await saveSketchToLocal().then((value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved!!"), duration: Duration(seconds: 1),));
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Canvas is Empty"), duration: Duration(seconds: 1),));
            }
          }, child: const Text("Save"))
        ],
      ),
      body: Stack(
        children: [

          /// [PAINT AREA]
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onPanStart: (details) {
                // debugPrint('START ####  Global Pos ${details.globalPosition} - Local Pos ${details.localPosition} - Timestamp ${details.sourceTimeStamp} - Kind ${details.kind}');
                setState(() {
                  line.add(details.globalPosition);
                });
              },
              onPanUpdate: (details) {
                // debugPrint('UPDATE ### Global Pos ${details.globalPosition} - Local Pos ${details.localPosition} - Timestamp ${details.sourceTimeStamp} - Delta ${details.delta} - Primary Delta ${details.primaryDelta}');
                setState(() {
                  line.add(details.globalPosition);
                });
              },
              onPanEnd: (details) {
                id++;
                line = [];
              },
              child: CustomPaint(
                painter: MyPainter(id: id, strokeColor: strokeColor, strokeWidth: strokeWidth, offsetList: line),
              ),
            ),
          ),

          /// [STROKE WIDTH CONTROLLER]
          Positioned(
            right: 10,
            bottom: 60,
            child: RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                width: 200,
                child: Slider(
                  thumbColor: Colors.purple[100],
                  activeColor: Colors.black38,
                  value: strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      strokeWidth = value;
                    });
                  }, max: 4, min: 0.2,),
              ),
            ),
          )
        ],
      ),

      /// [Undo and Clear screen Button]
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(heroTag: 'Undo',backgroundColor: Colors.purple[100],onPressed: () {
            setState(() {
              if (id > 0) {
                id--;
                linesMap.removeWhere((key, value) => key == id);
                line = [];
                // debugPrint("id $id sketch $linesMap");
              }
              linesMap.removeWhere((key, value) => value == []);
            });
          },child: const Icon(Icons.undo_sharp, color: Colors.black54,)),
          FloatingActionButton.small(heroTag: 'Clear',backgroundColor: Colors.purple[100],onPressed: () {
            setState(() {
              linesMap.clear();
              id = 0;
              line = [];
            });
          },child: const Icon(Icons.file_open_outlined, color: Colors.black54,)),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter{
  Offset? start;
  Offset? end;
  List<Offset>? offsetList = [];
  final int id;
  double strokeWidth;
  Color strokeColor;

  MyPainter({required this.id, this.offsetList, this.strokeWidth = 1, this.strokeColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = strokeColor..strokeWidth = strokeWidth;
    // debugPrint("error3 $id $offsetList $linesMap");

    if((!linesMap.keys.contains(id)) && offsetList?.length != 0){
      // debugPrint("error $id $offsetList $linesMap");
      linesMap[id] = offsetList ?? [];
    }
    // debugPrint("error2 $id $offsetList $linesMap");

    for (var v = 0; v < linesMap.length; v++) {
      if (linesMap[v] != []) {
        if (linesMap[v] != []) {
          for(int i = 0; i < linesMap[v]!.length; i++) {
            if (i < linesMap[v]!.length - 1) {
              start = linesMap[v]![i];
              end = linesMap[v]![i+1];
              canvas.drawLine(start!, end!, paint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}