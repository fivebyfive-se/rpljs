import 'package:flutter/material.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/helpers/buttons.dart';
import 'package:rpljs/widgets/txt.dart';

typedef AlertDialogBuilder = AlertDialog Function(BuildContext);

AlertDialogBuilder confirmDialogBuilder({
  String title,
  List<String> textLines,
  String cancelLabel = "Cancel",
  String confirmLabel = "Ok",
  Function() onConfirm,
  Function() onCancel
}){
  return (BuildContext context)
    => AlertDialog(
        title: Txt.h1(title),
        backgroundColor: Constants.theme.cardBackground,
        actionsPadding: EdgeInsets.all(8.0),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ...textLines.map((l) => Txt.p(l)).toList(),
            ],
          ),
        ),
        actions: <Widget>[
          btnDialog(
            label: cancelLabel,
            icon: Icons.cancel_outlined,
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
            color: Constants.theme.secondaryAccent
          ),
          btnDialog(
            label: confirmLabel,
            icon: Icons.subdirectory_arrow_left,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
          ),
        ],
      );
}