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
    Color foregroundDisabled,
    Gradient backgroundGradient,
    Color primaryAccent,
    Color secondaryAccent,
    Color tertiaryAccent,
    Color quaternaryAccent,
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
    Color inputAccent,
    Color inputAccentDisabled,
  }) :this.brightness = brightness,

      this.background = background,
      this.foreground = foreground, 
      this.foregroundDisabled = foregroundDisabled ?? foreground.withAlpha(0x80),

      this.backgroundGradient = backgroundGradient,

      this.primaryAccent = primaryAccent,
      this.secondaryAccent = secondaryAccent,
      this.tertiaryAccent = tertiaryAccent,
      this.quaternaryAccent = quaternaryAccent ?? tertiaryAccent,

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
      this.inputAccent = inputAccent ?? primaryAccent,
      this.inputAccentDisabled = inputAccentDisabled ?? inputText ?? foreground
    ;

  final Brightness brightness;
  
  final Color background;
  final Color foreground;
  final Color foregroundDisabled;
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
  final Color quaternaryAccent;

  final Color error;
  final Color warning;

  final Color historyBackground;
  final Color historyForeground;

  final Color varBackground;
  final Color varForeground;
  
  final Color inputBackground;
  final Color inputText;
  final Color inputAccent;
  final Color inputAccentDisabled;

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
      background: Constants.colors.darkGrey,
      foreground: Constants.colors.whiteish,
      foregroundDisabled: Constants.colors.greyish,
      backgroundGradient: LinearGradient(
        colors: [Constants.colors.darkGrey, Constants.colors.darkPink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight
      ),
      primaryAccent: Constants.colors.pink,
      secondaryAccent: Constants.colors.blue,
      tertiaryAccent: Constants.colors.green,
      quaternaryAccent: Constants.colors.yellow,

      error: Constants.colors.red,
      warning: Constants.colors.orange,

      cardBackground: Constants.colors.darkPink,

      appBarBackground: Constants.colors.purple,
      appBarForeground: Constants.colors.whiteish,

      terminalGradient: LinearGradient(
        colors: [
          Constants.colors.blackish,
          Constants.colors.blackish.withAlpha(0x20),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter
      ),
      terminalText: Constants.colors.whiteish,
      terminalBorder: Constants.colors.grey,

      historyBackground: Constants.colors.grey.withAlpha(0x80),
      historyForeground: Constants.colors.lightGrey,

      varBackground: Constants.colors.grey.withAlpha(0x80),
      varForeground: Constants.colors.lightPink,

      inputBackground: Constants.colors.blackish,
      inputText: Constants.colors.whiteish,
      inputAccent: Constants.colors.lightPink,
      inputAccentDisabled: Constants.colors.greyishPink

    );
}

class RpljsColors {
  @protected
  static Map<String, String> _hexColors = {
    'blackish': '#101014',
    'dark_grey': '#1F171F',
    'dark_pink': '#332633',
    'grey': '#474759',
    'light_grey': '#8585A6',
    'whiteish': '#F4FFF2',
    'greyish': '#626661',
    'pink': '#B312B3',
    'red': '#B31212',
    'orange': '#C26100',
    'yellow': '#E6C317',
    'green': '#55FF33',
    'blue': '#33BBFF',
    'purple': '#9933FF',
    'light_pink': '#FF33FF',
    'pale_pink': '#DA75FF',
    'greyish_pink': '#4D1F4D'
  };

  Color get blackish  => hexToColor(_hexColors['blackish']);
  Color get darkGrey  => hexToColor(_hexColors['dark_grey']);
  Color get darkPink  => hexToColor(_hexColors['dark_pink']);
  Color get grey      => hexToColor(_hexColors['grey']);
  Color get lightGrey => hexToColor(_hexColors['light_grey']);
  Color get whiteish  => hexToColor(_hexColors['whiteish']);
  Color get greyish   => hexToColor(_hexColors['greyish']);
  Color get pink      => hexToColor(_hexColors['pink']);
  Color get red       => hexToColor(_hexColors['red']);
  Color get orange    => hexToColor(_hexColors['orange']);
  Color get yellow    => hexToColor(_hexColors['yellow']);
  Color get green     => hexToColor(_hexColors['green']);
  Color get blue      => hexToColor(_hexColors['blue']);
  Color get purple    => hexToColor(_hexColors['purple']);
  Color get lightPink => hexToColor(_hexColors['light_pink']);
  Color get palePink  => hexToColor(_hexColors['pale_pink']);
  Color get greyishPink  => hexToColor(_hexColors['greyish_pink']);
}

