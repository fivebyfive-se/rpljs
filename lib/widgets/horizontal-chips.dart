import 'package:flutter/material.dart';
import 'package:rpljs/theme/text-style-helpers.dart';

typedef ChipCallback<T> = void Function(T);
typedef ConvertCallback<T> = String Function(T);

class HorizontalChips<T> extends StatefulWidget {
  HorizontalChips({
    @required this.items,
    @required this.labelConverter,
    this.tooltipConverter,
    this.reverse,
    this.backgroundColor,
    this.textColor,
    this.onPressed,
    this.onDeleted,
  });

  final List<T> items; 
  final bool reverse;
  final Color backgroundColor;
  final Color textColor;
  final ChipCallback<T> onPressed;
  final ChipCallback<T> onDeleted;
  final ConvertCallback<T> labelConverter;
  final ConvertCallback<T> tooltipConverter;

  @override
  _HorizontalChipsState<T> createState() => _HorizontalChipsState<T>();
}

class _HorizontalChipsState<T> extends State<HorizontalChips<T>> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
      ...(
        widget.reverse ?? false 
          ? widget.items.reversed.toList()
          : widget.items
      ).map((item) =>
        Container(
          child: InputChip(
            shape: RoundedRectangleBorder(),
            backgroundColor: widget.backgroundColor,
            label: Text(widget.labelConverter(item)),
            labelStyle: textStyleCode().copyWith(
              color: widget.textColor,
              fontWeight: FontWeight.w500
            ),
            tooltip: widget.tooltipConverter == null ? null 
              : widget.tooltipConverter(item),
              
            onPressed: widget.onPressed == null 
              ? null : () => widget.onPressed.call(item),

            onDeleted: widget.onDeleted == null
              ? null : () => widget.onDeleted.call(item),

            deleteIcon: widget.onDeleted == null 
              ? null : Icon(Icons.remove_circle_outline),

            deleteIconColor: widget.onDeleted == null
              ? null : widget.textColor.withAlpha(0x60),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 4.0,
            vertical: 2.0
          )
        )
      )
    ],
  );
  }
}