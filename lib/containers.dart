import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_joystick/flutter_joystick.dart';
import 'palette.dart';

import 'socket.dart';

enum Steering { speed, angle }

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
        child: Image.asset("assets/submarine.jpg"),
      ),
    );
  }
}

class Controls extends StatefulWidget {
  final ConnectSocket socket;

  const Controls({Key? key, required this.socket}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ControlsState();
}

class ControlsState extends State<Controls> {
  double s = 0.0, x = 0.0, y = 0.0;

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      send();
    });
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
                      listener: (StickDragDetails details) =>
                          {passer(details, Steering.speed)},
                      mode: JoystickMode.vertical,
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Livestream(),
                  ),
                  Expanded(
                    child: Joystick(
                      listener: (StickDragDetails details) =>
                          {passer(details, Steering.angle)},
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

  void passer(StickDragDetails details, Steering type) async {
    switch (type) {
      case Steering.speed:
        s = details.y;
        break;
      case Steering.angle:
        x = details.x;
        y = details.y;
        break;
    }
  }

  void send() async {
    String data =
        "s${s.toStringAsFixed(4)}x${x.toStringAsFixed(4)}y${y.toStringAsFixed(4)}";
    if (widget.socket.enabled) {
      widget.socket.write(data);
    }
    print(data);
  }
}

class Settings extends StatelessWidget {
  final ConnectSocket socket;

  const Settings({super.key, required this.socket});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: palette.accent,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: palette.text,
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => {socket.connect(ipAddress, portNum)},
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
