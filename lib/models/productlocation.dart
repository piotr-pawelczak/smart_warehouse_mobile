// To parse this JSON data, do
//
//     final productLocation = productLocationFromJson(jsonString);

import 'dart:convert';

ProductLocation productLocationFromJson(String str) => ProductLocation.fromJson(json.decode(str));

String productLocationToJson(ProductLocation data) => json.encode(data.toJson());

class ProductLocation {
  ProductLocation({
    required this.product,
    required this.location,
    required this.lotNumber,
    required this.quantity,
  });

  int product;
  int location;
  String lotNumber;
  int quantity;

  factory ProductLocation.fromJson(Map<String, dynamic> json) => ProductLocation(
    product: json["product"],
    location: json["location"],
    lotNumber: json["lot_number"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "product": product.toString(),
    "location": location.toString(),
    "lot_number": lotNumber,
    "quantity": quantity.toString(),
  };
}
