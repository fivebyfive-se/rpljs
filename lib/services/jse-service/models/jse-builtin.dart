import './jse-func.dart';

abstract class JseBuiltin {
  JseBuiltin(this.name, {this.doc});

  final String name;
  final String doc;

  dynamic get value;

  JseBuiltin withName(String name);
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
  JseBuiltinFunc withName(String newName)
    => JseBuiltinFunc(newName, func, numArgs, doc: doc);

  @override
  JseBuiltinFunc withPrefix(String prefix)
    => withName("$prefix.$name");
}

class JseBuiltinObject extends JseBuiltin {
  JseBuiltinObject(String name, List<JseBuiltinFunc> funcs, {String doc})
    : this.funcs = funcs ?? [],
      super(name, doc: doc);

  final List<JseBuiltinFunc> funcs;

  void add(String name, JseFunc func, int numArgs, {String doc})
    => funcs.add(JseBuiltinFunc(name, func, numArgs, doc: doc));
  

  List<JseBuiltinFunc> get nsFuncs =>
    funcs.map(
      (f) => f.withPrefix(name)
    ).toList();

  List<String> get funcNames =>
    funcs.map((f) => f.name).toList();

  @override
  dynamic get value => funcs;

  @override
  JseBuiltinObject withName(String newName)
    => JseBuiltinObject(newName, funcs, doc: doc);

  @override
  JseBuiltinObject withPrefix(String prefix)
    => withName("$prefix.$name");
}
