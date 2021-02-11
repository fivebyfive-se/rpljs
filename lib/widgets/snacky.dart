import 'package:flutter/material.dart';

import 'package:rpljs/config/constants.dart';
import 'package:rpljs/helpers/text-style-helpers.dart';

import 'package:rpljs/widgets/txt.dart';

class Snacky {
  Snacky({this.context});
  Snacky.of(this.context);

  final BuildContext context;

  @protected
  ScaffoldMessengerState
  get _messengerState => ScaffoldMessenger.of(context);

  void show(String text, {
    Color backgroundColor,
    Color labelColor,
    String actionLabel,
    Function() onAction,
    Color actionColor
  })
    => _messengerState.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? Constants.theme.cardBackground,
        content: Txt.p(
          text,
          style: textColor(labelColor ?? Constants.theme.foreground)
        ),
        action: actionLabel != null && onAction != null
          ? SnackBarAction(
            label: actionLabel,
            textColor: actionColor ?? Constants.theme.primaryAccent,
            onPressed: onAction
          )
          : null
      )
    );

  void showAction(String text, { String actionLabel, Function() onAction })
    => show(text, actionLabel: actionLabel, onAction: onAction);

  void showError(String text)
    => show(text, labelColor: Constants.theme.error);

  void showInfo(String text)
    => show(text, labelColor: Constants.theme.secondaryAccent);
}