import 'package:hive/hive.dart';

import 'package:rpljs/extensions/string-extensions.dart';

import '_base-model.dart';

@HiveType()
class SnippetModel extends BaseModel {
  static const String hiveBoxName = "_snippets";

  @override
  final String boxName = hiveBoxName;

  /// JavaScript code
  @HiveField(1)
  String content;

  /// Name
  @HiveField(2)
  String label;

  /// Whether to run this snippet whenever
  /// the app starts
  @HiveField(3)
  bool runOnInit;

  /// Create new instance
  SnippetModel({this.label, this.content, this.runOnInit = false}) 
    : super();

  SnippetModel.fromAdapter(String uuid, String label, String content, bool onInit)
    : label = label,
      content = content,
      runOnInit = onInit,
      super.fromAdapter(uuid);

  @override
  bool isEqual(BaseModel other)
    => (other is SnippetModel) && (other.uuid == uuid);

  @override
  int compareTo(BaseModel other)
    => (other as SnippetModel).label.compareTo(label);

  @override
  String toString() => content.truncate();

  @override
  SnippetModel clone() => SnippetModel
    .fromAdapter(uuid, label, content, runOnInit);
}

class SnippetAdapter extends TypeAdapter<SnippetModel> {
  @override
  final typeId = 1;

  @override
  SnippetModel read(BinaryReader reader) {
    final uuid = reader.readString();
    final label = reader.readString();
    final content = reader.readString();
    final onInit = reader.readBool();

    return SnippetModel.fromAdapter(uuid, label, content, onInit);
  }
  @override
  void write(BinaryWriter writer, SnippetModel obj) {
    writer.writeString(obj.uuid);
    writer.writeString(obj.label);
    writer.writeString(obj.content);
    writer.writeBool(obj.runOnInit);
  }
}