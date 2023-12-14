import 'dart:io';

import 'dart:async';

const recievedDataMax = 128;

const defualtPortNum = 2300;
var defaultHandshake = SocketHandshake('MayIDr1ve', 'YesYouMay');

_returnNull(dynamic arg) => null;

class SocketHandshake {
  String send;
  String recv;

  SocketHandshake(this.send, this.recv);
}

class SocketResult {
  bool ok = true;
  SocketException? error;

  SocketResult(this.ok, [this.error]);
}

class ConnectSocket {
  Socket? socket;
  bool enabled = false;

  bool verified = false;

  Future<SocketResult> connect(String ipAddress, int portNum,
      SocketHandshake handshake,
      {Function(SocketException) onError = _returnNull,
      Function onDisconnect = _returnNull,
      Function(List<int>) onRecieved = _returnNull}) async {
    try {
      socket = await Socket.connect(ipAddress, portNum);
    } on SocketException catch (error) {
      return SocketResult(false, error);
    }

    socket?.write(handshake.send); // Send handshake
    socket?.listen(
      (List<int> data) async {
        if (verified) {
          print('Server: $data');
          onRecieved(data);
        } else {
          var recv = String.fromCharCodes(data);
          print('Handshake: $recv');
          if (recv == handshake.recv) {
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
    Future.delayed(const Duration(seconds: 3), () {
      if (!verified && enabled) {
        onError(const SocketException('Handshake failed'));
        close();
      }
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
    socket?.add(data);
  }

  Future<void> close() async {
    await socket?.close();
    verified = false;
    enabled = false;
  }
}
