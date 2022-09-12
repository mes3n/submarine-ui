import 'dart:io';
import 'dart:typed_data';

import 'dart:async';

// move to main or so
const int portNum = 2300;
const String ipAddress = '192.168.50.79'; // local ip to pc
const int recievedDataMax = 128;

class ConnectSocket {
  String ipAddress = "";
  int portNum = 2300;

  late Socket socket;
  bool enabled = false;

  late Timer callbackTimer;
  Function callbackFunc = () {}; // callbackFunc?
  int callbackTime = 1;

  Future<bool> connect(String passIPAddress, int passPortNum) async {
    ipAddress = passIPAddress;
    portNum = passPortNum;

    try {
      socket = await Socket.connect(ipAddress, portNum);
    } on SocketException {
      print("Socket Exception");
      return false;
    }
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

    socket.listen(
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        print('Server: $serverResponse');
      },
      onError: (error) {
        print(error);
        socket.destroy();
      },
      onDone: () {
        print('Server left.');
        socket.destroy();
      },
    );
    callbackTimer = Timer.periodic(Duration(seconds: callbackTime), (timer) {
      callbackFunc();
    });
    enabled = true;

    return true;
  }

  Future<void> send(List<int> data) async {
    print('Client: $data');
    socket.add(data); // as uint8 list
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> close() async {
    callbackTimer.cancel();
    await socket.close();
    enabled = false;
  }
}
