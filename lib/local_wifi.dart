import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';

Future<Function> scanNetwork(
    Function updateIPs, Function progressCallback, Function finish) async {
  if (Platform.isIOS) {
    // something with poor support for ios with lan_scanner
    const port = 80;
    // a port which is available by default, 22 interferes with ssh
    await (NetworkInfo().getWifiIP()).then((ip) async {
      final String subnet = ip!.substring(0, ip.lastIndexOf('.'));
      for (var i = 0; i < 256; i++) {
        String ip = '$subnet.$i';
        await Socket.connect(ip, port,
                timeout: const Duration(milliseconds: 50))
            .then((socket) async {
          await InternetAddress(socket.address.address).reverse().then((value) {
            updateIPs(socket.address.address);
            print(value.host);
          });
          socket.destroy();
        }).catchError((error) {
          // very bad solution, would not recommend
          if (!error.toString().contains("Connection timed out")) {
            updateIPs(ip);
          }
        });

        progressCallback(i / 255);
      }
    });
    return () {};
  }

  late final String subnet;
  try {
    subnet = ipToCSubnet(await (NetworkInfo().getWifiIP()) ?? "");
  } on RangeError {
    print("Error: Subnet not found.");
    finish();
    return () {};
  }

  final scanner = LanScanner().icmpScan(subnet, progressCallback: (progress) {
    progressCallback(progress);
  });
  return scanner.listen((HostModel device) {
    print("Found host: ${device.ip}");
    updateIPs(device.ip);
  }, onDone: () {
    finish();
  }).cancel;
  // await for (HostModel device in scanner) {
  // print("Found host: ${device.ip}");
  // updateIPs(device);
  // }
}
