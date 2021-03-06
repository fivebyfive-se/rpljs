import 'package:rpljs/config/rpljs-theme.dart';

class Constants {
  static const appTitle = 'Rpljs';

  static RpljsTheme theme = RpljsTheme.defaultDark;
  static RpljsColors colors = RpljsColors();

  static const fontMono = 'SpaceMono';
  static const fontSans = 'SpaceGrotesk';
  static const fontSizeBase   = 20.0;
  static const fontSizeSmall  = 16.0;
  static const fontSizeLarge  = 23.0;
  static const fontSizeXLarge = 27.0;

  static const iconSizeXLarge = 32.0;
  static const iconSizeLarge  = 23.0;

  static const sizeBase       = 9.0;

  static List<String> javascriptKeywords = [
'break',
'case',
'catch',
'class',
'const',
'continue',
'debugger',
'default',
'delete',
'do',
'else',
'export',
'extends',
'finally',
'for',
'function',
'if',
'import',
'in',
'instanceof',
'new',
'return',
'super',
'switch',
'this',
'throw',
'try',
'typeof',
'var',
'void',
'while',
'with',
'yield',
  ];
}
