import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductType {
  String? name;
  Color? textColor;
  Color? buttonColor;

  ProductType({
    this.name,
    this.textColor,
    this.buttonColor,
  });

  ProductType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    textColor = json['color'];
    buttonColor = json['color'];
  }
}
