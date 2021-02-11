import 'package:flutter/cupertino.dart';

Spacer spex(int flex)
  => Spacer(flex: flex);

Expanded flexp(int flex, Widget child)
  => Expanded(flex: flex, child: child);
