import './jse-func.dart';

abstract class JseBuiltin {
  JseBuiltin(this.name, {this.doc});

  final String name;
  final String doc;

  dynamic get value;
  JseBuiltin withPrefix(String prefix);
}

class JseBuiltinFunc extends JseBuiltin {
  JseBuiltinFunc(String name, this.func, this.numArgs, {String doc})
    : super(name, doc: doc);
  
  final JseFunc func;
  final int numArgs;

  @override
  dynamic get value => func;

  @override
  JseBuiltinFunc withPrefix(String prefix)
    => JseBuiltinFunc(
      "$prefix.$name",
      func,
      numArgs,
      doc: doc
    );
}

class JseBuiltinObject extends JseBuiltin {
  JseBuiltinObject(String name, this.objFuncs, {String doc})
    : super(name, doc: doc);

  final List<JseBuiltinFunc> objFuncs;

  List<JseBuiltinFunc> get funcs =>
    objFuncs.map(
      (f) => f.withPrefix(name)
    ).toList();

  List<String> get funcNames =>
    funcs.map((f) => f.name).toList();

  @override
  dynamic get value => funcs;

  @override
  JseBuiltinObject withPrefix(String prefix)
    => JseBuiltinObject(
      "$prefix.$name",
      objFuncs,
      doc: doc
    );
}
