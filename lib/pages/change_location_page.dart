import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_warehouse_mobile/models/product.dart';
import 'package:smart_warehouse_mobile/models/productlocation.dart';
import 'package:smart_warehouse_mobile/pages/change_location_scanners/source_location_scanner.dart';
import 'package:smart_warehouse_mobile/pages/change_location_scanners/target_location_scanner.dart';
import 'package:smart_warehouse_mobile/services/api_manager.dart';
import 'change_location_scanners/product_location_scanner.dart';
import 'package:smart_warehouse_mobile/services/globals.dart';

class ChangeLocationPage extends StatefulWidget {
  const ChangeLocationPage({Key? key}) : super(key: key);

  @override
  _ChangeLocationPageState createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends State<ChangeLocationPage> {

  void refresh(dynamic childValue) {
    setState(() {
      Globals.productId = childValue;
    });
  }

  @override
  Widget build(BuildContext context) {

    Globals.productId = 0;
    Globals.sourceLocationId = 0;
    Globals.targetLocationId = 0;
    Globals.sourceLotNumber = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zmiana lokalizacji'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade800),
        child: Center(
          child: Column(
            children: [
              scanProductButton(context),
              scanSourceLocationButton(context),
              scanTargetLocationButton(context),
              printProductId(context),
            ],
          ),
        ),
      ),
    );
  }
}


Column scanProductButton(context) {
  return Column(
    children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
      ElevatedButton(
          child: const Text('Skanuj kod produktu', style: TextStyle(color: Colors.white70),),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF198754),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  ProductLocationScanner()));
          }),
    ],
  );
}

Column scanSourceLocationButton(context) {
  return Column(
    children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
      ElevatedButton(
          child: const Text('Skanuj kod lokalizacji źródłowej', style: TextStyle(color: Colors.white70),),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF198754),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  SourceLocationScanner()));
          }),
    ],
  );
}

Column scanTargetLocationButton(context) {
  return Column(
    children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
      ElevatedButton(
          child: const Text('Skanuj kod lokalizacji docelowej', style: TextStyle(color: Colors.white70),),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF198754),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  TargetLocationScanner()));
          }),
    ],
  );
}

Column printProductId(context) {
  return Column(
    children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
      const Text('Potwierdź zmianę lokalizacji', style: TextStyle(color: Colors.white70),),
      ElevatedButton(
          child: const Text('Potwierdź', style: TextStyle(color: Colors.white70),),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF198754),
          ),
          onPressed: () async {

            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            var token = sharedPreferences.getString("token");

            Future<Product> fProduct = API_Manager().getProduct(Globals.productId, token!);
            var product = await fProduct;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Potwierdź zmianę lokalizacji'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('Produkt: ${product.name}'),
                        Text('Numer Partii: ${Globals.sourceLotNumber}'),
                        Text('Lokalizacja źródłowa: ${Globals.sourceLocationName}'),
                        Text('Lokalizacja docelowa: ${Globals.targetLocationName}'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          handleTransfer(token, Globals.productId, Globals.sourceLocationId, Globals.targetLocationId, Globals.sourceLotNumber);
                          Globals.productId = 0;
                          Globals.sourceLocationId = 0;
                          Globals.targetLocationId = 0;
                          Globals.sourceLotNumber = '';
                          Navigator.of(context).pop();
                        }
                    )
                  ],
                );
              },
            );
          }),
    ],
  );
}

void handleTransfer(token, productId, sourceLocationId, targetLocationId, sourceLotNumber) async {
  Future<int> fSourceProductLocationId = API_Manager().getProductLocationId(
      productId, sourceLocationId, sourceLotNumber, token
  );

  Future<int> fTargetProductLocationId = API_Manager().getProductLocationId(
      productId, targetLocationId, sourceLotNumber, token
  );

  int sourceId = await fSourceProductLocationId;
  int targetId = await fTargetProductLocationId;

  Future<ProductLocation> fSourceLocation = API_Manager().getProductLocation(sourceId, token);
  var sourceLocation = await fSourceLocation;
  var sourceQuantity = sourceLocation.quantity - 1;

  if(sourceQuantity == 0) {
    API_Manager().removeProductLocation(sourceId, token);
  } else {
    API_Manager().updateProductLocationQuantity(sourceId, sourceQuantity, token);
  }

  if(targetId != 0) {
    Future<ProductLocation> fTargetLocation = API_Manager().getProductLocation(targetId, token);
    var targetLocation = await fTargetLocation;
    var quantity = targetLocation.quantity + 1;
    API_Manager().updateProductLocationQuantity(targetId, quantity, token);
  } else {
    var newProductLocation = ProductLocation(
        product: productId, location: targetLocationId,
        lotNumber: sourceLotNumber, quantity: 1
    );
    API_Manager().creteProductLocation(newProductLocation, token);

  }
}