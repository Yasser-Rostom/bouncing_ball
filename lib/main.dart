import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'circle_painter.dart';


void main() {
  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});


  @override
  State<MainApp> createState() => _MainAppState();
}


class _MainAppState extends State<MainApp> with TickerProviderStateMixin{
  bool _needRepaint = false;
  Offset? _centerOffset;

  bool _isAnimationInProgress = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,

      home: Builder(builder: (context) {
        final canvasSize = MediaQuery.of(context).size;
        _centerOffset ??= Offset(canvasSize.width / 2, canvasSize.height / 2);
        final circleShape = CirclePainter(
          needRepaint: _needRepaint,
          center: _centerOffset!,
          radius: 25,
        );
        return Scaffold(appBar:AppBar(title: const Text("A Demo Game By Yasser Ros."),),
          body: Center(
            child: SizedBox(
              height: canvasSize.height,
              width: canvasSize.width,
              child: GestureDetector(
                onPanStart: (details) {
                  // pick the ball only if the animation is not
                  // in progress and the user hits upon the ball
                  if (_isAnimationInProgress == false &&
                      (circleShape.hitTest(details.localPosition) ?? false)) {
                    setState(() {
                      _needRepaint = true;
                    });
                  }
                },
                onPanUpdate: (details) {
                  // prevent to set a new center position for hits out of
                  // the ball bounds and if the animation is in progress as well
                  if (_isAnimationInProgress == false && _needRepaint) {
                    setState(() {
                      _centerOffset = details.localPosition;
                    });
                  }
                },onPanEnd: (details) {
                // prevent to set a new center position for hits out of
                // the ball bounds and if the animation is in progress as well
                if (_isAnimationInProgress == false && _needRepaint) {
                  _runAnimation(
                    details.velocity.pixelsPerSecond,
                    const Size(50, 50),
                    canvasSize,
                  );
                }
              },
                child: ColoredBox(
                  color: Colors.black,
                  child: CustomPaint(
                    foregroundPainter: circleShape,
                    size: canvasSize,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
   void _runAnimation(
       Offset pixelsPerSecond,
       Size objectSize,
       Size canvasSize,
       ) {
     _isAnimationInProgress = true;


     // create an unbounded because physis simulations don't have bounds
     final controller = AnimationController.unbounded(
       vsync: this,
     );


     final velocityPixelsPerSecond = pixelsPerSecond.distance;


     // creates a FrictionSimulation. The drag parameter goes from 1 (infinite
     // friction) to 0 (none friction). The position parameter tell the flutter
     // engine in witch point should start to refresh the UI; e.g. if the
     // velocity is 100 pixel/sec, position is 200 and none friction will start
     // to send updates on the 2nd sec
     final simulation = FrictionSimulation(0.05, 0, velocityPixelsPerSecond);


     // the angle in radians from 0 to pi for +y and 0 to -pi for -y
     var direction = pixelsPerSecond.direction;


     // as the controller always increment the value this variable is needed
     // to get the differential increment
     var movedDistance = 0.0;


     controller.addListener(() {
       setState(() {
         // differential offset is the incremental point from the last frame
         final differentialOffset =
         Offset.fromDirection(direction, controller.value - movedDistance);


         // calculates the new center with the given increment
         _centerOffset = Offset(_centerOffset!.dx + differentialOffset.dx,
             _centerOffset!.dy + differentialOffset.dy);


         // update walkedDistance to get the differentialOffset in next frame
         movedDistance = controller.value;


         // check if should bounce on the canvas left bound
         if (_centerOffset!.dx - objectSize.width / 2 < 0) {
           direction = pi - direction;
           _centerOffset = Offset(
             objectSize.width / 2,
             _centerOffset!.dy,
           );
         }
         // check if should bounce on the canvas top bound
         if (_centerOffset!.dy - objectSize.height / 2 < 0) {
           direction = -direction;
           _centerOffset = Offset(
             _centerOffset!.dx,
             objectSize.height / 2,
           );
         }
         // check if should bounce on the canvas right bound
         if (_centerOffset!.dx + objectSize.width / 2 > canvasSize.width) {
           direction = pi - direction;
           _centerOffset = Offset(
             canvasSize.width - objectSize.width / 2,
             _centerOffset!.dy,
           );
         }
         // check if should bounce on the canvas bottom bound
         if (_centerOffset!.dy + objectSize.height / 2 > canvasSize.height) {
           direction = -direction;
           _centerOffset = Offset(
             _centerOffset!.dx,
             canvasSize.height - objectSize.height / 2,
           );
         }
       });});


     // run the animation and dispose the controller when finish
     controller.animateWith(simulation).whenComplete(() {
       setState(() {
         _needRepaint = false;
         _isAnimationInProgress = false;
         controller.dispose();
       });
     });
   }
}

