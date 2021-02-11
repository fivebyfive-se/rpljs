import 'package:flutter/painting.dart';
import 'package:rpljs/config/constants.dart';

const double minFactor = 0.5;

double size(double factor, {double base = Constants.sizeBase})
  => factor * base;
double minSize() => size(minFactor);

EdgeInsetsGeometry padding({
  double horizontal = minFactor,
  double vertical = minFactor
}) => EdgeInsets.symmetric(
    horizontal: size(horizontal),
    vertical:   size(vertical)
  );