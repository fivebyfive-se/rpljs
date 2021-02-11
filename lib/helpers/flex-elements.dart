import 'package:flutter/material.dart';

Spacer spex(int flex)
  => Spacer(flex: flex);

Expanded flexp(int flex, Widget child)
  => Expanded(flex: flex, child: child);
