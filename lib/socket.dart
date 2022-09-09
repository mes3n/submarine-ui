import 'dart:io';
import 'dart:typed_data';

// move to main or so
const int portNum = 2300;
const String ipAddress = '192.168.50.79';
const int recievedDataMax = 128;

class ConnectSocket {
  late String ipAddress;
  late int portNum;

  late Socket socket;
  bool enabled = false;

  // ConnectSocket();

  Future<void> connect(ipAddress, portNum) async {
    ipAddress = ipAddress;
    portNum = portNum;

    socket = await Socket.connect(ipAddress, portNum);
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
    enabled = true;
  }

  Future<void> write(data) async {
    print('Client: $data');
    socket.write(data);
    await Future.delayed(const Duration(seconds: 1));
  }

  void close() async {
    await socket.close();
  }
}
