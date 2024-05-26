import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@Collection()
class AppSettings {
  //app id
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}