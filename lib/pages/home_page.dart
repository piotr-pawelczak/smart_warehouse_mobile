import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_warehouse_mobile/pages/login_page.dart';
import 'package:smart_warehouse_mobile/pages/product_scanner_page.dart';
import 'package:smart_warehouse_mobile/pages/change_location_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Warehouse",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              sharedPreferences.remove("token");
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => const LoginPage()),
                      (Route<dynamic> route) => false);
            },
            child: const Text("Wyloguj", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              primary: Colors.grey.shade900,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade800),
        child: Center(
          child: Column(
            children: [
              scanProductButton(context),
              changeLocationButton(context),
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
      const Text('Wczytaj informacje o produkcie', style: TextStyle(color: Colors.white70),),
      ElevatedButton(
          child: const Text('Skanuj kod produktu', style: TextStyle(color: Colors.white70),),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF198754),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProductScanner()));
          }),
    ],
  );
}

Column changeLocationButton(context) {
  return Column(
    children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
      const Text('Zmiana lokalizacji produktu', style: TextStyle(color: Colors.white70),),
      ElevatedButton(
          child: const Text('Zmień lokalizację', style: TextStyle(color: Colors.white70),),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF198754),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  ChangeLocationPage()));
          }),
    ],
  );
}
