import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smart_warehouse_mobile/services/globals.dart';

class TargetLocationScanner extends StatefulWidget {
  const TargetLocationScanner({Key? key}) : super(key: key);

  @override
  _TargetLocationScannerState createState() => _TargetLocationScannerState();
}

class _TargetLocationScannerState extends State<TargetLocationScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skanowanie lokalizacji docelowej'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 5,
          cutOutSize: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {

      controller.pauseCamera();
      var splitData = (scanData.code)!.split(";");
      var codeType = splitData[0];
      print(codeType);

      if(codeType == 'location') {

        var locationId = int.parse(splitData[1]);
        var locationName = splitData[2];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Informacje o lokalizacji'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Lokalizacja: $locationName'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Globals.targetLocationId = locationId;
                      Globals.targetLocationName = locationName;
                    }
                )
              ],
            );
          },
        ).then((value) => controller.resumeCamera());
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Zeskanuj prawidłowy kod lokalizacji'),
              actions: <Widget>[
                TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                )
              ],
            );
          },
        ).then((value) => controller.resumeCamera());
      }

    });
  }
}
