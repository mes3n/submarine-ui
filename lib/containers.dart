import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
        child: Image.asset("assets/submarine.jpg"), // this will be a stream
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
  void initState() {
    widget.socket.callback = () {
      send();
    };
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
                        passer(details, Steering.speed);
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
                        passer(details, Steering.angle);
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

  void passer(StickDragDetails details, Steering type) {
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

  void send() {
    if (widget.socket.enabled) {
      ByteData data = ByteData.sublistView(Int8List(12));

      // because each float has reversed bytes, this will be reversed
      data.setFloat32(0, y);
      data.setFloat32(4, x);
      data.setFloat32(8, s);

      // then this has to be reversed to set each float byte in the right direction and at the right place
      widget.socket.send(List.from(data.buffer.asUint8List().reversed));
      print(data.buffer.asUint8List().toList());
    }
  }
}

enum ConnectionState { connected, disconnected }

class Settings extends StatefulWidget {
  final ConnectSocket socket;

  const Settings({Key? key, required this.socket}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  static ConnectionState connectionState = ConnectionState.disconnected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
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
            onPressed: () async {
              if (connectionState == ConnectionState.disconnected) {
                if (await widget.socket.connect(ipAddress, portNum)) {
                  setState(() {
                    connectionState = ConnectionState.connected;
                  });
                }
              } else if (connectionState == ConnectionState.connected) {
                await widget.socket.close();
                setState(() {
                  connectionState = ConnectionState.disconnected;
                });
              }
            },
            child: Text(connectionState == ConnectionState.disconnected
                ? "Connect"
                : "Disconnect"),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }
}
