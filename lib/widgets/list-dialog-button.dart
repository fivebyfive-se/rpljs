import 'package:flutter/material.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/theme/size-helpers.dart';
import 'package:rpljs/widgets/builders/confirm-dialog-builder.dart';
import 'package:rpljs/widgets/buttons.dart';
import 'package:rpljs/widgets/text-elements.dart';

class ListDialogButton<T> extends StatelessWidget {
  ListDialogButton({
    this.icon,
    this.tooltip,
    this.color,
    this.dialogTitle,
    this.emptyText,
    this.itemBuilder,
    this.cancelButton = true
  }) :
    assert(icon != null),
    assert(itemBuilder != null);

  final IconData icon;
  final String tooltip;
  final Color color;
  final String dialogTitle;
  final String emptyText;
  final ListDialogItemBuilder<T> itemBuilder;
  final bool cancelButton;

  @override
  Widget build(BuildContext context) 
    => IconButton(
        icon: Icon(icon, color: color ?? Constants.theme.foreground),
        tooltip: tooltip,
        onPressed: () => showDialog(
          context: context,
          builder: listDialogBuilder(
            title: dialogTitle ?? "Choose item",
            emptyText: emptyText ?? "No items found...",
            cancelButton: cancelButton,
            items: itemBuilder(context).toList(),
          )
        )
      );
}

typedef ListDialogItemBuilder<T> 
  = List<ListDialogItem<T>> Function(BuildContext context);

AlertDialogBuilder listDialogBuilder<T>({
  String title,
  String emptyText,
  List<ListDialogItem<T>> items,
  bool cancelButton = true,
}) => (BuildContext context)
  => AlertDialog(
      title: Txt.h1(title),
      backgroundColor: Constants.theme.cardBackground,
      insetPadding: padding(horizontal: 4, vertical: 4),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            items.isEmpty 
              ? ListTile(
                title: Txt.strong(emptyText)
              ) : Divider(),
              ...items.map((item) => item.child).toList()          
          ])
      ),
      actions: cancelButton == false ? <Widget>[] : <Widget>[
        btnDialog(
          icon: Icons.arrow_back,
          label: "Cancel",
          color: Constants.theme.background,
          foregroundColor: Constants.theme.foreground,
          onPressed: () => Navigator.of(context).pop()
        )
      ]
  );

class ListDialogItem<T> {
  final T value;
  final Widget child;

  ListDialogItem({this.value, this.child});
}