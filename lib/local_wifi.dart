import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

Future<void> scanNetwork(List<String> ipAddresses, int ms) async {
  const port = 22;
  await (NetworkInfo().getWifiIP()).then((ip) async {
    final String subnet = ip!.substring(0, ip.lastIndexOf('.'));
    for (var i = 0; i < 256; i++) {
      String ip = '$subnet.$i';
      await Socket.connect(ip, port, timeout: Duration(milliseconds: ms))
          .then((socket) async {
        await InternetAddress(socket.address.address).reverse().then((value) {
          ipAddresses.add(socket.address.address);
        }).catchError((error) {
          print('Error: $error');
        });
        socket.destroy();
      }).catchError((error) {
        // very bad solution (i think), please teach me tho
        if (!error.toString().contains("Connection timed out")) {
          ipAddresses.add(ip);
        }
      });
    }
  });
}

void main() async {
  List<String> ipAddresses = ["n1"];
  await scanNetwork(ipAddresses, 5);
  print(ipAddresses);
  // await Socket.connect("localhssost", 22, timeout: Duration(milliseconds: 100))
  //     .then((socket) async {
  //   await InternetAddress(socket.address.address).reverse().then((value) {
  //     print(value.host);
  //     print(socket.address.address);
  //   }).catchError((error) {
  //     print(socket.address.address);
  //     print('Error: $error');
  //   });
  //   socket.destroy();
  // }).catchError((error) => throw (error));
}
