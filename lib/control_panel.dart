import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'flutter_joystick/flutter_joystick.dart';

import 'socket.dart';
import 'palette.dart';

class Livestream extends StatelessWidget {
  const Livestream({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 5, color: palette.lHighlight),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Image.asset("assets/submarine.jpg"), // this will be a stream
      ),
    );
  }
}

enum Steering { speed, angle }

class Controls extends StatefulWidget {
  final ConnectSocket socket;

  const Controls({Key? key, required this.socket}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ControlsState();
}

class ControlsState extends State<Controls> {
  double s = 0.0, x = 0.0, y = 0.0;
  late Timer callbackTimer;

  @override
  void initState() {
    callbackTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      send();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: palette.backgorund,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Joystick(
                      listener: (StickDragDetails details) {
                        s = details.y;
                      },
                      mode: JoystickMode.vertical,
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Livestream(),
                  ),
                  Expanded(
                    child: Joystick(
                      listener: (StickDragDetails details) {
                        x = details.x;
                        y = details.y;
                      },
                      mode: JoystickMode.all,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void send() {
    if (widget.socket.enabled) {
      ByteData data = ByteData.sublistView(Int8List(12));

      // because each float has reversed bytes, this will be reversed
      data.setFloat32(0, y);
      data.setFloat32(4, x);
      data.setFloat32(8, s);

      // then this has to be reversed to set each float byte in the right direction and at the right place
      widget.socket.send(List.from(data.buffer.asUint8List().reversed));
      // print(data.buffer.asUint8List().toList());
    }
  }

  @override
  void dispose() {
    callbackTimer.cancel();
    super.dispose();
  }
}
