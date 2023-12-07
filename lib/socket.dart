import 'dart:io';
import 'dart:typed_data';

import 'dart:async';

// move to main or so
const int defualtPortNum = 2300;
const int recievedDataMax = 128;

class ConnectSocket {
  String ipAddress = "";
  int portNum = defualtPortNum;

  Socket? socket;
  bool enabled = false;

  Timer? callbackTimer;
  Function callbackFunc = () {};
  int callbackTimeMs = 500;

  Future<String> connect(String ipAddress, int portNum) async {
    try {
      socket = await Socket.connect(ipAddress, portNum);
    } on SocketException catch (error) {
      return error.toString();
    }
    print(
        'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}');

    socket?.listen(
      (Uint8List data) {
        final serverResponse = data;
        print('Server: $serverResponse');
      },
      onError: (error) {
        print(error);
        close();
      },
      onDone: () {
        close();
      },
    );
    callbackTimer =
        Timer.periodic(Duration(milliseconds: callbackTimeMs), (timer) {
      callbackFunc();
    });
    enabled = true;

    return "Success";
  }

  Future<void> send(List<int> data) async {
    print('Client: $data');
    socket?.add(data); // as uint8 list
    // await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> close() async {
    callbackTimer?.cancel();
    await socket?.close();
    enabled = false;
  }
}
