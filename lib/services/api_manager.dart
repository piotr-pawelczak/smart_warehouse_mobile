import 'dart:convert';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:smart_warehouse_mobile/constants/strings.dart';
import 'package:smart_warehouse_mobile/models/product.dart';
import 'package:smart_warehouse_mobile/models/productlocation.dart';

class API_Manager {

  Future<Product> getProduct(int id, String token) async {
    var client = http.Client();
    var product = null;

    Map<String, String> data = {
      'Authorization': 'TOKEN ' + token
    };

    try {
      var response = await client.get(
          Uri.parse(Strings.urlGetProducts + id.toString()), headers: data);

      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);
        product = Product.fromJson(jsonMap);
      }
    } on Exception {
      return product;
    }

    return product;
  }

  Future<int> getProductLocationId(int productId, int locationId, String lotNumber, token) async {
    var client = http.Client();
    var productLocationId = 0;

    Map<String, String> dataHeaders = {
      'Authorization': 'TOKEN ' + token,
    };

    Map<String, String> dataParameters = {
      'product': productId.toString(),
      'location': locationId.toString(),
      'lot_number': lotNumber
    };

    final uri = Uri.https(
        "smart-warehouse-web.herokuapp.com", "api/product-location-search/",
        dataParameters);

    try {
      var response = await client.get(uri, headers: dataHeaders);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);
        productLocationId = jsonMap["id"];
      }
    } on Exception {
      return productLocationId;
    }
    return productLocationId;
  }

  Future<ProductLocation> getProductLocation(int id, String token) async {
    var client = http.Client();
    var productLocation = null;

    Map<String, String> data = {
      'Authorization': 'TOKEN ' + token
    };

    try {
      var response = await client.get(
          Uri.parse(Strings.urlProductLocationDetail + id.toString()), headers: data);

      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);
        productLocation = ProductLocation.fromJson(jsonMap);
      }
    } on Exception {
      return productLocation;
    }

    return productLocation;
  }

  void updateProductLocationQuantity(int id, int quantity, String token) async {
    var client = http.Client();

    Map<String, String> dataHeaders = {
      'Authorization': 'TOKEN ' + token
    };

    Map<String, String> dataBody = {
      'quantity': quantity.toString()
    };

    var response = await client.patch(Uri.parse(Strings.urlProductLocationDetail + id.toString()), headers: dataHeaders, body: dataBody);

    if (response.statusCode != 200) {
      throw Exception('Failed to update product location');
    }
  }

  void creteProductLocation(ProductLocation productLocation, String token) async {
    var productLocationJson = productLocation.toJson();
    var client = http.Client();

    Map<String, String> data = {
      'Authorization': 'TOKEN ' + token
    };

    var response = await client.post(Uri.parse(Strings.urlProductLocationCreate), headers: data, body: productLocationJson);

    if (response.statusCode != 201) {
      throw Exception('Failed to create product location');
    }


  }

  void removeProductLocation(int id, String token) async {
    var client = http.Client();
    Map<String, String> dataHeaders = {
      'Authorization': 'TOKEN ' + token
    };

    await client.delete(Uri.parse(Strings.urlProductLocationDetail + id.toString()), headers: dataHeaders);
  }
}
