import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';

extension ColorExtensions on Color {
  Color brighten({double amt}) {
    final hsv = HSVColor.fromColor(this);
    final value = hsv.value + amt;
    final saturation = (hsv.value + amt) <= 1.0
        ? hsv.saturation
        : max(0.0, hsv.saturation - (value - 1.0));

    return hsv.withValue(min(1.0, value)).withSaturation(saturation).toColor();
  }
  
  Color darken({double amt}) {
    final hsv = HSVColor.fromColor(this);
    final value = hsv.value - amt;
    final saturation = (hsv.value - amt) <= 0.0
        ? hsv.saturation
        : min(1.0, hsv.saturation + (1.0 + (value)));

    return hsv.withValue(max(0.0, value)).withSaturation(saturation).toColor();
  }
}