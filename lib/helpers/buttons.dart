import 'package:flutter/material.dart';
import 'package:rpljs/config/index.dart' show Constants;
import 'package:rpljs/helpers/size-helpers.dart';

import 'package:rpljs/widgets/txt.dart';

Widget btnLabel({
  String label,
  Color labelColor
}) => Txt.p(
  label, 
  style: TextStyle(color: labelColor)
);

Widget btnLabelIcon({
  Color backgroundColor,
  String label,
  Color labelColor,
  IconData icon,
  Color iconColor,
  EdgeInsetsGeometry padding,
  void Function() onPressed
}) {
  labelColor = labelColor ?? Constants.theme.foreground;

  return FlatButton.icon(
    color: backgroundColor ?? Constants.theme.primaryAccent,
    icon: Icon(icon, color: iconColor ?? labelColor),
    label: btnLabel(label: label, labelColor: labelColor),
    onPressed: onPressed,
    padding: padding
  );
}

Widget btnIcon({
  IconData icon,
  void Function() onPressed,
  Color color
}) => IconButton(
  icon: Icon(icon, color: color ?? Constants.theme.primaryAccent),
  onPressed: onPressed
);

Widget btnDialog({
  String label,
  IconData icon,
  void Function() onPressed,
  Color color,
  Color foregroundColor
})
  => btnLabelIcon(
    backgroundColor: color ?? Constants.theme.primaryAccent,
    icon: icon,
    iconColor: foregroundColor ?? Constants.theme.background,
    label: label,
    labelColor: foregroundColor ?? Constants.theme.background,
    onPressed: onPressed,
    padding: padding(horizontal: 2, vertical: 1),
  );