// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_joystick/flutter_joystick.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

const Joystick omniSteering = Joystick(
  listener: passer,
);

const Joystick depthSteering = Joystick(
  mode: JoystickMode.vertical,
  listener: passer,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hello Row",
      color: const Color(0xFF121212),
      home: _RowTest(),
    );
  }
}

class _RowTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF121212),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: omniSteering,
          ),
          Expanded(
            flex: 3,
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 5,
                        color: const Color(0xFF242424),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Image.asset("assets/submarine.jpg"),
                )),
          ),
          const Expanded(
            child: depthSteering,
          ),
        ],
      ),
    ));
  }
}

passer(details) {
  print(details.x);
  print(details.y);
}
