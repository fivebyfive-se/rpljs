import 'package:flutter/material.dart';
import 'package:rpljs/theme/text-style-helpers.dart';

class Txt extends StatelessWidget {
  Txt({this.text, this.type, this.style});

  Txt.p(this.text, {this.style})
    : type = TxtType.paragraph;

  Txt.h1(this.text, {this.style})
    : type = TxtType.title;
  Txt.h2(this.text, {this.style})
    : type = TxtType.subtitle;

  Txt.strong(this.text, {this.style})
    : type = TxtType.strong; 
  Txt.em(this.text, {this.style})
    : type = TxtType.em; 
    
  Txt.light(this.text, {this.style})
    : type = TxtType.light; 

  Txt.code(this.text, {this.style})
    : type = TxtType.code; 

  final String text;
  final TxtType type;
  final TextStyle style;

  TextStyle get computedStyle 
    => typeToStyle(type).merge(style ?? TextStyle());

  @override
  Widget build(BuildContext context) {
    return Text(text, style: computedStyle);
  }
}

TextStyle typeToStyle(TxtType type) {
  switch (type) {
    case TxtType.code:
      return textStyleCode();
    case TxtType.subtitle:
      return textStyleSubtitle();
    case TxtType.title:
      return textStyleTitle();
    case TxtType.strong:
      return textStyleBody().copyWith(fontWeight: FontWeight.bold);
    case TxtType.em:
      return textStyleBody().copyWith(fontStyle: FontStyle.italic);
    case TxtType.light:
      return textStyleBody().copyWith(fontWeight: FontWeight.w300);
    case TxtType.paragraph:
    default:
      return textStyleBody();
  }
}

enum TxtType {
  paragraph,
  code,
  title,
  subtitle,
  strong,
  em,
  light
}