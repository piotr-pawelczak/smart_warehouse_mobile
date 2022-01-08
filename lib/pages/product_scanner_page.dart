import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_warehouse_mobile/models/product.dart';
import 'package:smart_warehouse_mobile/services/api_manager.dart';


class ProductScanner extends StatefulWidget {
  const ProductScanner({Key? key}) : super(key: key);

  @override
  _ProductScannerState createState() => _ProductScannerState();
}

class _ProductScannerState extends State<ProductScanner> {
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
        title: const Text('Skanowanie produktu'),
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
      codeType = codeType.substring(1);

      if(codeType == 'product') {

        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        var token = sharedPreferences.getString("token");
        var productId = int.parse(splitData[1]);
        var lotNumber = splitData[3];
        lotNumber = lotNumber.substring(0, lotNumber.length -1);

        Future<Product> fProduct = API_Manager().getProduct(productId, token!);
        var product = await fProduct;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Informacje o produkcie'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Produkt: ${product.name}'),
                    Text('SKU: ${product.sku}'),
                    Text('Numer partii: $lotNumber'),
                    Text('Waga: ${product.weight} kg'),

                  ],
                ),
              ),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Zeskanuj prawidłowy kod produktu'),
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
