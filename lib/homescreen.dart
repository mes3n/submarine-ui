import 'package:flutter/material.dart';

import 'containers.dart';
import 'palette.dart';

import 'socket.dart';

enum WidgetMarker { controls, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  WidgetMarker selectedWidget = WidgetMarker.controls;

  ConnectSocket socket = ConnectSocket();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.backgorund,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: getCustomContainer(),
          ),
          Align(
            alignment: const Alignment(0.98, 0.95),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accent,
              ),
              child: PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert_outlined,
                ),
                color: palette.hHighlight,
                itemBuilder: (context) => <PopupMenuItem>[
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          color: palette.accent,
                        ),
                        Text("  Settings",
                            style: TextStyle(color: palette.accent)),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedWidget = WidgetMarker.settings;
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.gamepad_outlined,
                          color: palette.accent,
                        ),
                        Text("  Controls",
                            style: TextStyle(color: palette.accent)),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedWidget = WidgetMarker.controls;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (socket.enabled) {
      socket.close();
    }
    super.dispose();
  }

  Widget getCustomContainer() {
    switch (selectedWidget) {
      case WidgetMarker.controls:
        return Controls(socket: socket);
      case WidgetMarker.settings:
        return Settings(socket: socket);
    }
  }
}
