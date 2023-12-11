import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'local_wifi.dart';
import 'palette.dart';
import 'socket.dart';

enum ConnectionState { connected, loading, disconnected }

class Settings extends StatefulWidget {
  final ConnectSocket socket;

  const Settings({Key? key, required this.socket}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  static int portNum = defualtPortNum;
  static List<String> localIPAddresses = [];

  static var connectionState = ConnectionState.disconnected;

  static bool isScanning = false;
  Function closeScan = () {};

  static double loadingProgress = 0.0;

  @override
  void initState() {
    if (loadingProgress <= 0.0) {
      getLocalIPaddresses();
    }
    super.initState();
  }

  void getLocalIPaddresses() async {
    if (!isScanning) {
      isScanning = true;
      localIPAddresses = [];
      closeScan = await scanNetwork(updateLocalIPAdresses, (progress) {
        if (!mounted) {
          loadingProgress = progress;
        } else {
          setState(() {
            loadingProgress = progress;
          });
        }
      }, () {
        isScanning = false;
      });
    }
  }

  Function onIPAdressesUpdate = () {};
  void updateLocalIPAdresses(String ip) async {
    if (localIPAddresses.contains(ip)) return;

    localIPAddresses.add(ip);
    localIPAddresses.sort((a, b) {
      try {
        return int.parse(a.split('.').last)
            .compareTo(int.parse(b.split('.').last));
      } on FormatException catch (_) {
        return a.compareTo(b);
      }
    });

    if (mounted) {
      onIPAdressesUpdate();
    }
  }

  Future<String?> getConnectionInfo(BuildContext context) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          onIPAdressesUpdate = () {
            setState(() {});
          };
          return SimpleDialog(
            backgroundColor: palette.hHighlight,
            children: <Widget>[
              ...localIPAddresses.map((ip) => SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, ip);
                    },
                    child: Text(
                      ip,
                      style: TextStyle(color: palette.text),
                    ),
                  )),
              // ...dialogOptions,
              SimpleDialogOption(
                  onPressed: () {
                    final textField = TextEditingController();
                    showText("Enter custom IP", textField).then((_) {
                      Navigator.pop(context, textField.text);
                    });
                  },
                  child: Text(
                    "Custom",
                    style: TextStyle(color: palette.text),
                  )),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: palette.text),
                  )),
            ],
          );
        });
      },
    );

    onIPAdressesUpdate = () {};
    return result;
  }

  Future<void> showText(String text, [TextEditingController? textField]) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            text,
            style: TextStyle(color: palette.text),
          ),
          content: textField != null
              ? TextField(
                  controller: textField,
                  style: TextStyle(color: palette.text),
                )
              : null,
          backgroundColor: palette.hHighlight,
          actions: <Widget>[
            if (textField != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  textField.text = "";
                },
                child: Text(
                  "CANCEL",
                  style: TextStyle(color: palette.text),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(color: palette.text),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: AlignmentDirectional.topCenter,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Settings",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: palette.text),
            ),
            const SizedBox(height: 4),
            Text(
              "Configure settings for connecting and communicating with the submarine.",
              style: TextStyle(fontSize: 16, color: palette.lText),
            ),
            const SizedBox(height: 16),
            Text(
              "Connection",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 128,
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: palette.text,
                      backgroundColor: palette.accent,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () async {
                      if (connectionState == ConnectionState.disconnected) {
                        String ip = await getConnectionInfo(context) ?? "";
                        if (ip.isNotEmpty) {
                          setState(() {
                            connectionState = ConnectionState.loading;
                          });
                          SocketResult result = await widget.socket.connect(
                              ip, portNum, onError: (SocketException error) {
                            setState(() {
                              connectionState = ConnectionState.disconnected;
                            });
                            showText(error.toString());
                          }, onDisconnect: () {
                            setState(() {
                              connectionState = ConnectionState.disconnected;
                            });
                          });
                          if (result.ok) {
                            updateLocalIPAdresses(ip);
                            setState(() {
                              connectionState = ConnectionState.connected;
                            });
                          } else {
                            setState(() {
                              connectionState = ConnectionState.disconnected;
                            });
                            String msg = result.error.toString();
                            await showText(
                                msg.toString().substring(0, msg.indexOf(" (")));
                          }
                        }
                      } else if (connectionState == ConnectionState.connected) {
                        await widget.socket.close();
                        setState(() {
                          connectionState = ConnectionState.disconnected;
                        });
                      }
                    },
                    child: connectionState == ConnectionState.loading
                        ? Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                                color: palette.text, size: 30))
                        : Text(connectionState == ConnectionState.disconnected
                            ? "Connect"
                            : "Disconnect"),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 128,
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: palette.text,
                      backgroundColor: palette.accent,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: isScanning
                        ? () async {
                            await closeScan();
                            setState(() {
                              isScanning = false;
                            });
                          }
                        : () {
                            // localIPAddresses = [];
                            getLocalIPaddresses();
                            setState(() {});
                          },
                    child: isScanning
                        ? const Text("Stop Scan")
                        : const Text("Scan Network"),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 128,
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: palette.text,
                      backgroundColor: palette.accent,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      final textField = TextEditingController();
                      textField.text = portNum.toString();
                      showText("Enter A Port Number", textField).then((_) {
                        if (textField.text.isEmpty) return;
                        int? val = int.tryParse(textField.text);
                        if (val == null) {
                          showText("Enter a valid number");
                        } else {
                          portNum = val;
                        }
                      });
                    },
                    child: const Text("Set Net Port"),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                    width: 200,
                    height: 40,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Scan progress: ${loadingProgress.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            color: palette.text,
                          ),
                        ),
                        LinearProgressIndicator(
                          value: loadingProgress,
                          color: palette.accent,
                          backgroundColor: palette.text,
                        ),
                      ],
                    ))
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Submarine (Beta)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: palette.text,
              ),
            ),
            const Row(
              children: <Widget>[],
            ),
          ],
        ));
  }

  @override
  void dispose() {
    closeScan();
    isScanning = false;

    super.dispose();
  }
}
