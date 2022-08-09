import 'package:flutter/material.dart';

import 'containers.dart';
import 'palette.dart';

enum WidgetMarker { controls, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  WidgetMarker selectedWidget = WidgetMarker.controls;

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
                  Icons.more_vert,
                ),
                color: palette.highlight,
                itemBuilder: (context) => <PopupMenuItem>[
                  PopupMenuItem(
                    child:
                        Text("Settings", style: TextStyle(color: palette.text)),
                    onTap: () {
                      setState(() {
                        selectedWidget = WidgetMarker.settings;
                      });
                    },
                  ),
                  PopupMenuItem(
                    child:
                        Text("Controls", style: TextStyle(color: palette.text)),
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

  Widget getCustomContainer() {
    switch (selectedWidget) {
      case WidgetMarker.controls:
        return const Controls();
      case WidgetMarker.settings:
        return const Settings();
    }
  }
}
