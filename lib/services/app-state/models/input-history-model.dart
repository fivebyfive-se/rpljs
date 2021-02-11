import 'package:hive/hive.dart';

import 'package:rpljs/extensions/string-extensions.dart';

import '_base-model.dart';

@HiveType()
class InputHistoryModel extends BaseModel {
  @override
  final String boxName = "_history";

  /// The saved input string
  @HiveField(1)
  String content;

  /// Whether this string has been saved to favourites
  @HiveField(2)
  bool isFavourite;

  /// When the input was entered
  @HiveField(3)
  DateTime timestamp;

  InputHistoryModel({this.content, this.isFavourite = false})
    : timestamp = DateTime.now(),
      super();

  InputHistoryModel.fromAdapter(String uuid, String content, bool isFav, DateTime timestamp)
    : content = content,
      isFavourite = isFav,
      timestamp = timestamp,
      super.fromAdapter(uuid);

  @override
  bool isEqual(BaseModel other)
    => (other is InputHistoryModel) && (other.content == content);

  @override
  int compareTo(BaseModel other)
    => (other as InputHistoryModel).timestamp.compareTo(timestamp);


  @override
  String toString() => content.truncate();

  @override
  InputHistoryModel clone() => InputHistoryModel
    .fromAdapter(uuid, content, isFavourite, timestamp);
}

class InputHistoryAdapter extends TypeAdapter<InputHistoryModel> {
  @override
  final int typeId = 3;

  @override
  InputHistoryModel read(BinaryReader reader) {
    final uuid = reader.readString();
    final content = reader.readString();
    final isFav = reader.readBool();
    final micros = reader.readInt();

    return InputHistoryModel.fromAdapter(
      uuid,
      content,
      isFav,
      DateTime.fromMillisecondsSinceEpoch(micros)
    );
  }

  @override
  void write(BinaryWriter writer, InputHistoryModel obj) {
    writer.writeString(obj.uuid);
    writer.writeString(obj.content);
    writer.writeBool(obj.isFavourite);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}