import 'package:flutter/material.dart';
import 'package:rpljs/theme/text-style-helpers.dart';

class Txt extends StatelessWidget {
  Txt({this.text, this.type, TextStyle style, List<TxtType> extraTypes})
    : style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];

  final String text;
  final TxtType type;
  final TextStyle style;
  final List<TxtType> extraTypes;


  Txt.p(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.paragraph,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];

  Txt.h1(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.title,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];
  Txt.h2(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.subtitle,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];

  Txt.strong(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.strong,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];
  Txt.em(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.em,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];

  Txt.light(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.light,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];

  Txt.code(this.text, {TextStyle style, List<TxtType> extraTypes})
    : type = TxtType.code,
      style = style ?? TextStyle(),
      extraTypes =  extraTypes ?? <TxtType>[];

  // TextStyle get computedStyle 
  //   => typeToStyle(type).merge(style ?? TextStyle());

  @override
  Widget build(BuildContext context) {
    final computedStyle = typeToStyle(type)
      .merge(style)
      .merge(
        extraTypes.isEmpty 
          ? TextStyle()
          : extraTypes.map((t) => typeToStyle(t))
            .reduce((prev, curr) => prev.merge(curr))
      );
    
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