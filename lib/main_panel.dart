import 'package:flutter/material.dart';

import 'control_panel.dart';
import 'settings_panel.dart';

import 'palette.dart';

import 'socket.dart';

enum WidgetMarker { controls, settings }

class MainPanel extends StatefulWidget {
  const MainPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainPanelState();
}

class MainPanelState extends State<MainPanel> {
  var selectedWidget = WidgetMarker.controls;
  var socket = ConnectSocket();

  static Map<WidgetMarker, Widget> widgetMap = {
    WidgetMarker.controls: Controls(socket: ConnectSocket()),
    WidgetMarker.settings: Settings(socket: ConnectSocket()),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.backgorund,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: widgetMap[selectedWidget],
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
                        const SizedBox(width: 4),
                        Text("Settings",
                            style: TextStyle(color: palette.accent)),
                        const SizedBox(width: 20),
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
                        const SizedBox(width: 4),
                        Text("Controls",
                            style: TextStyle(color: palette.accent)),
                        const SizedBox(width: 20),
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
    socket.close();
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
