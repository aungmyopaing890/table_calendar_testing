import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Product {
  int? id;
  String? name;
  String? type;
  double price = 0;
  String imageLink = "";
  String? description;
  Color? productColor;

  Product(
      {this.id,
      this.name,
      this.type,
      this.price = 0,
      required this.imageLink,
      required this.description,
      required this.productColor});

  Product.initial()
      : id = 0,
        name = '',
        price = 0.0,
        imageLink = '',
        description = '';

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    price = double.parse(json['price']);
    imageLink = json['image_link'];
    description = json['description'];
    productColor = HexColor.fromHex(json['color']);
  }
}

class ProductColor {
  Color? color;

  ProductColor({
    this.color,
  });

  ProductColor.fromJson(Map<String, dynamic> json) {
    color = HexColor.fromHex(json['hex_value']);
  }
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString";
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
