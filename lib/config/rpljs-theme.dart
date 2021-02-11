import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/helpers/color-helpers.dart';
import 'package:rpljs/helpers/text-style-helpers.dart';

class RpljsTheme {
  RpljsTheme({
    Brightness brightness,
    Color background,
    Color foreground,
    Gradient backgroundGradient,
    Color primaryAccent,
    Color secondaryAccent,
    Color tertiaryAccent,
    Color error,
    Color warning,
    Color cardBackground,
    Color appBarBackground,
    Color appBarForeground,
    Gradient terminalGradient,
    Color terminalText,
    Color terminalBorder,
    Color historyBackground,
    Color historyForeground,
    Color varBackground,
    Color varForeground,
    Color inputBackground,
    Color inputText,
    Color inputAccent
  }) :this.brightness = brightness,

      this.background = background,
      this.foreground = foreground, 

      this.backgroundGradient = backgroundGradient,

      this.primaryAccent = primaryAccent,
      this.secondaryAccent = secondaryAccent,
      this.tertiaryAccent = tertiaryAccent,

      this.error = error,
      this.warning = warning ?? error,

      this.cardBackground = cardBackground ?? background,

      this.appBarBackground = appBarBackground ?? cardBackground,
      this.appBarForeground = appBarForeground ?? foreground,

      this.terminalGradient = terminalGradient ?? LinearGradient(colors: [cardBackground, foreground.withAlpha(0)]),
      this.terminalText = terminalText ?? foreground,
      this.terminalBorder = terminalBorder ?? background,

      this.historyBackground = historyBackground ?? cardBackground,
      this.historyForeground = historyForeground ?? secondaryAccent,

      this.varBackground = varBackground ?? cardBackground,
      this.varForeground = varForeground ?? tertiaryAccent,
      
      this.inputBackground = inputBackground ?? background,
      this.inputText = inputText ?? foreground,
      this.inputAccent = inputAccent ?? primaryAccent
    ;

  final Brightness brightness;
  
  final Color background;
  final Color foreground;
  final Gradient backgroundGradient;

  final Color cardBackground;

  final Color appBarBackground;
  final Color appBarForeground;

  final Gradient terminalGradient;
  final Color terminalText;
  final Color terminalBorder;

  final Color primaryAccent;
  final Color secondaryAccent;
  final Color tertiaryAccent;

  final Color error;
  final Color warning;

  final Color historyBackground;
  final Color historyForeground;

  final Color varBackground;
  final Color varForeground;
  
  final Color inputBackground;
  final Color inputText;
  final Color inputAccent;

  ThemeData toThemeData() => ThemeData(
    brightness:      brightness,
    backgroundColor: background,
    canvasColor:     background,

    primaryColor:    primaryAccent,
    accentColor:     secondaryAccent,
    splashColor:     tertiaryAccent,
    
    errorColor:      error,
    
    cardColor:       cardBackground,
    buttonColor:     cardBackground,

    dialogBackgroundColor: cardBackground,
    
    inputDecorationTheme: InputDecorationTheme(
      prefixStyle: textStyleCode().copyWith(color: inputAccent),
      filled: true,
      fillColor: inputBackground,
      border: InputBorder.none,
    ),
    
    textTheme: TextTheme(
      bodyText1: textStyleBody(),
      bodyText2: textStyleBody()
        .copyWith(fontSize: Constants.fontSizeSmall),
      headline1: textStyleTitle(),
      headline2: textStyleSubtitle()
    ),
    fontFamily: Constants.fontSans,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static RpljsTheme get defaultDark 
    => RpljsTheme(
      brightness: Brightness.dark,
      background: RpljsColors.darkGrey,
      foreground: RpljsColors.whiteish,
      backgroundGradient: LinearGradient(
        colors: [RpljsColors.darkGrey, RpljsColors.darkPink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight
      ),
      primaryAccent: RpljsColors.pink,
      secondaryAccent: RpljsColors.blue,
      tertiaryAccent: RpljsColors.green,

      error: RpljsColors.red,
      warning: RpljsColors.orange,

      cardBackground: RpljsColors.darkPink,

      appBarBackground: RpljsColors.purple,
      appBarForeground: RpljsColors.whiteish,

      terminalGradient: LinearGradient(
        colors: [
          RpljsColors.blackish,
          RpljsColors.blackish.withAlpha(0x20),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter
      ),
      terminalText: RpljsColors.whiteish,
      terminalBorder: RpljsColors.grey,

      historyBackground: RpljsColors.blackish,
      historyForeground: RpljsColors.orange,

      varBackground: RpljsColors.grey.withAlpha(0x80),
      varForeground: RpljsColors.lightPink,

      inputBackground: RpljsColors.blackish,
      inputText: RpljsColors.whiteish,
      inputAccent: RpljsColors.lightPink

    );
}

class RpljsColors {
  @protected
  static Map<String, String> _hexColors = {
    'blackish': '#101014',
    'dark_grey': '#1F171F',
    'dark_pink': '#332633',
    'grey': '#474759',
    'whiteish': '#F4FFF2',
    'pink': '#B312B3',
    'red': '#B31212',
    'orange': '#C26100',
    'yellow': '#E6C317',
    'green': '#55FF33',
    'blue': '#33BBFF',
    'purple': '#9933FF',
    'light_pink': '#FF33FF',
    'pale_pink': '#BF26BF'
  };

  static Color get blackish  => hexToColor(_hexColors['blackish']);
  static Color get darkGrey  => hexToColor(_hexColors['dark_grey']);
  static Color get darkPink  => hexToColor(_hexColors['dark_pink']);
  static Color get grey      => hexToColor(_hexColors['grey']);
  static Color get whiteish  => hexToColor(_hexColors['whiteish']);
  static Color get pink      => hexToColor(_hexColors['pink']);
  static Color get red       => hexToColor(_hexColors['red']);
  static Color get orange    => hexToColor(_hexColors['orange']);
  static Color get yellow    => hexToColor(_hexColors['yellow']);
  static Color get green     => hexToColor(_hexColors['green']);
  static Color get blue      => hexToColor(_hexColors['blue']);
  static Color get purple    => hexToColor(_hexColors['purple']);
  static Color get lightPink => hexToColor(_hexColors['light_pink']);
  static Color get palePink  => hexToColor(_hexColors['pale_pink']);
}

