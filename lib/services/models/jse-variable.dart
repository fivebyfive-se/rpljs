import 'package:dartjsengine/dartjsengine.dart';

class JseVariable {
  JseVariable({this.name, this.jsObject});

  final String  name;
  final JsObject jsObject;
  
  dynamic get value       => jsObject?.valueOf;
  String  get valueString => jsObjectToValueString(jsObject);
  String  get displayString 
              => jsObjectToValueString(jsObject, display: true); 

  String toJsSnippet() => "var $name = $valueString;";

  @override
  String toString() => "$name [$displayString]";
}

JseVariable jsVarFromValue(String name, dynamic value)
  => JseVariable(name: name, jsObject: jsObjectFromValue(value));

JsObject jsObjectFromValue(dynamic value) {
  if (value is bool) {
    return JsBoolean(value);
  } else if (value is double) {
    return JsNumber(value);
  } else if (value is String) {
    return JsString(value);
  } else if (value is Map<String, dynamic>) {
    final jsObject = JsObject();
    jsObject.properties.addAll(
      value.map((k, v) => MapEntry(k, jsObjectFromValue(v)))
    );
    return jsObject;
  } else {
    return value as JsObject;
  }
}

String jsObjectToValueString(JsObject obj, {bool display = false}) {
  if (obj == null || obj is JsNull) {
    return "null";
  } else if (obj is JsBoolean) {
    return obj.valueOf.toString();
  } else if (obj is JsNumber) {
    return (obj.valueOf).toString();
  } else if (obj is JsString) {
    return "'" + (obj.valueOf).toString() + "'";
  } else if (obj is JsFunction) {
    return display ? "[Function]" : "function () {}";
  } else if (obj is JsArray) {
    return display ? "[Array${obj.valueOf.length}]" 
      : "[" + 
        (obj.valueOf).map((i) => jsObjectToValueString(i)).join(", ")
      + "]";
  } else if (obj is JsObject) {
    return display ? "[Object]" : "{"
      + obj.jsValueOf.properties.entries
          .map((e) => e.key.toString() + ": " + jsObjectToValueString(e.value))
      .join(", ")
    + "}";
  }
  return (display ? "?" : "undefined");
} 
