import 'package:flutter/material.dart';

import 'flutter_joystick/flutter_joystick.dart';
import 'palette.dart';

enum Steering { vertical, yawAndPropel }

class Livestream extends StatelessWidget {
  const Livestream({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 5, color: palette.highlight),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Image.asset("assets/submarine.jpg"),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({super.key});

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
                      listener: (details) =>
                          passer(details, Steering.yawAndPropel),
                      mode: JoystickMode.all,
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Livestream(),
                  ),
                  Expanded(
                    child: Joystick(
                      listener: (details) => passer(details, Steering.vertical),
                      mode: JoystickMode.vertical,
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
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

passer(details, type) {
  switch (type) {
    case Steering.yawAndPropel:
      print("forward");
      break;
    case Steering.vertical:
      print("rotate");
      break;
  }
  print("x: ${details.x}");
  print("y: ${details.y}");
}
