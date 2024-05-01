import 'package:flutter/material.dart';

Map<int, List<Offset>?> linesMap = {};

class DrawSketch extends StatefulWidget {
  const DrawSketch({Key? key}) : super(key: key);

  @override
  State<DrawSketch> createState() => _DrawSketchState();
}

class _DrawSketchState extends State<DrawSketch> {
  int id = 0;
  List<Offset> line = [];
  double strokeWidth = 1;
  Color strokeColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// [PAINT AREA]
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onPanStart: (details) {
                debugPrint('START ####  Global Pos ${details.globalPosition} - Local Pos ${details.localPosition} - Timestamp ${details.sourceTimeStamp} - Kind ${details.kind}');
                setState(() {
                  line.add(details.globalPosition);
                });
              },
              onPanUpdate: (details) {
                debugPrint('UPDATE ### Global Pos ${details.globalPosition} - Local Pos ${details.localPosition} - Timestamp ${details.sourceTimeStamp} - Delta ${details.delta} - Primary Delta ${details.primaryDelta}');
                setState(() {
                  line.add(details.globalPosition);
                });
              },
              onPanEnd: (details) {
                debugPrint(details.primaryVelocity.toString());
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
          FloatingActionButton.small(backgroundColor: Colors.purple[100],onPressed: () {
            setState(() {
              if (id > 0) {
                id--;
                linesMap.removeWhere((key, value) => key == id);
                line = [];
                debugPrint("id $id sketch $linesMap");
              }
              linesMap.removeWhere((key, value) => value == []);
            });
          },child: const Icon(Icons.undo_sharp, color: Colors.black54,)),
          FloatingActionButton.small(backgroundColor: Colors.purple[100],onPressed: () {
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
      debugPrint("error $id $offsetList $linesMap");
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