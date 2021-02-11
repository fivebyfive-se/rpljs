import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:rpljs/config/index.dart' show Constants;

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

EdgeInsetsGeometry margin({
  double horizontal = minFactor,
  double vertical = minFactor,
})
  => padding(horizontal: horizontal, vertical: vertical);

EdgeInsetsGeometry paddingOnly({
  double top = 0, double bottom = 0, double left = 0, double right = 0
})
  => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

EdgeInsetsGeometry marginOnly({
  double top = 0, double bottom = 0, double left = 0, double right = 0
})
  => paddingOnly(left: left, top: top, right: right, bottom: bottom);