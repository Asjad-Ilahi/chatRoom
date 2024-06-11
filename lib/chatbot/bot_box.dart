import 'package:hive/hive.dart';
import 'package:trictux_chatroom/hive_local_database/bot_dataset.dart';


class ChatBotBox {
  static Box<Bot> getData() => Hive.box<Bot>('chat');
}