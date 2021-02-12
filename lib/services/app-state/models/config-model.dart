import 'package:hive/hive.dart';
import 'package:rpljs/services/jse-service.dart' show JseVerbosity;

import './_base-model.dart';

@HiveType()
class ConfigModel extends BaseModel {
  static const String hiveBoxName = "_config"; 

  @override
  final String boxName = hiveBoxName;

  /// How verbose to be
  @HiveField(1)
  JseVerbosity verbosity;

  /// Whether to hide suggestions above input field
  @HiveField(2)
  bool hideSuggestions;

  ConfigModel({JseVerbosity verbosity, bool hideSuggestions}) 
    : verbosity = verbosity ?? JseVerbosity.normal,
      hideSuggestions = hideSuggestions ?? false,
      super();

  ConfigModel.fromAdapter(String uuid, int verbosityIndex, bool hideSuggestions)
    :verbosity = JseVerbosity.values[verbosityIndex], 
     hideSuggestions = hideSuggestions,
     super.fromAdapter(uuid);

  @override
  ConfigModel clone()
    => ConfigModel(
      verbosity: verbosity,
      hideSuggestions: hideSuggestions
    );

  @override
  int compareTo(BaseModel other)
    => (other as ConfigModel).verbosity.index - verbosity.index; 

  @override
  bool isEqual(BaseModel other)
    => other.uuid == uuid;
}

class ConfigAdapter extends TypeAdapter<ConfigModel> {
  @override
  final int typeId = 5;

  @override
  ConfigModel read(BinaryReader reader) {
    final uuid = reader.readString();
    final verbosityIndex = reader.readInt();
    final hideSuggestions = reader.readBool();

    return ConfigModel.fromAdapter(
      uuid,
      verbosityIndex,
      hideSuggestions
    );
  }

  @override
  void write(BinaryWriter writer, ConfigModel obj) {
    writer.writeString(obj.uuid);
    writer.writeInt(obj.verbosity.index);
    writer.writeBool(obj.hideSuggestions);
  }
}