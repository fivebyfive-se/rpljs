import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

abstract class BaseModel extends HiveObject {
  final String boxName = "none";

  /// Unique Id
  @HiveField(0)
  final String uuid;

  BaseModel()
    : uuid = Uuid().v4();

  /// Domain-specific compare
  bool isEqual(BaseModel other);

  /// Domain-specific compare
  int  compareTo(BaseModel other);

  BaseModel clone(); 

  BaseModel.fromAdapter(String uuid)
    : uuid = uuid;
}
