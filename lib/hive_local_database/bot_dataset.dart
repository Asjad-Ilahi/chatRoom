import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
part 'bot_dataset.g.dart';

@HiveType(typeId: 1)
class Bot extends HiveObject{
  @HiveField(0)
  String name;

  @HiveField(1)
  String instruction;

  Bot({required this.name, required this.instruction});
}