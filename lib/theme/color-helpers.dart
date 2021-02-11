import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  String normalizedHex = hex.replaceAll('#', '');
  if (normalizedHex.length == 3) {
    normalizedHex = normalizedHex[0] + normalizedHex[0] +
      normalizedHex[1] + normalizedHex[1] +
      normalizedHex[2] + normalizedHex[2];
  }
  final r = int.tryParse(normalizedHex.substring(0,2), radix: 16) ?? 0;
  final g = int.tryParse(normalizedHex.substring(2,4), radix: 16) ?? 0;
  final b = int.tryParse(normalizedHex.substring(4,6), radix: 16) ?? 0;

  return Color.fromRGBO(r, g, b, 1.0); 
}

String colorToHex(Color color, {bool includeHash = false}) {
  final toHex = (int n) => n.toRadixString(16).padLeft(2, "0"); 
  return (includeHash ? '#' : '') + 
    toHex(color.red) + 
      toHex(color.green) + 
        toHex(color.blue);
}


