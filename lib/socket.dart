import 'dart:io';

import 'dart:async';

const int defualtPortNum = 2300;
const int recievedDataMax = 128;

const String handshakeSend = 'MayIDr1ve';
const String handshakeRecv = 'YesYouMay';

_returnNull(dynamic arg) => null;

class SocketResult {
  bool ok = true;
  SocketException? error;

  SocketResult(this.ok, [this.error]);
}

class ConnectSocket {
  String ipAddress = '';
  int portNum = defualtPortNum;

  Socket? socket;
  bool enabled = false;

  bool verified = false;

  Timer? callbackTimer;
  Function callbackFunc = () {};
  int callbackTimeMs = 500;

  Future<SocketResult> connect(String ipAddress, int portNum,
      {Function(SocketException) onError = _returnNull,
      Function onDisconnect = _returnNull,
      Function(List<int>) onRecieved = _returnNull}) async {
    try {
      socket = await Socket.connect(ipAddress, portNum);
    } on SocketException catch (error) {
      return SocketResult(false, error);
    }

    socket?.write(handshakeSend); // Send handshake
    socket?.listen(
      (List<int> data) async {
        if (verified) {
          print('Server: $data');
          onRecieved(data);
        } else {
          var handshake = String.fromCharCodes(data);
          print('Handshake: $handshake');
          if (handshake == handshakeRecv) {
            verified = true;
          }
        }
      },
      onError: (error) async {
        onError(error);
        if (enabled) close();
      },
      onDone: () async {
        onDisconnect();
        if (enabled) close();
      },
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!verified && enabled) {
        onError(const SocketException('Handshake failed'));
        close();
      }
    });

    callbackTimer =
        Timer.periodic(Duration(milliseconds: callbackTimeMs), (timer) {
      callbackFunc();
    });
    enabled = true;

    print(
        'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}');

    return SocketResult(true);
  }

  Future<void> send(List<int> data) async {
    if (!(verified && enabled)) {
      print('Not verified or enabled');
      return;
    }
    print('Client: $data');
    socket?.add(data); // as uint8 list
    // await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> close() async {
    callbackTimer?.cancel();
    await socket?.close();
    verified = false;
    enabled = false;
  }
}
