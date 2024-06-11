import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trictux_chatroom/auth/auth_gate.dart';
import 'package:trictux_chatroom/chatbot/const.dart';
import 'package:trictux_chatroom/coloring/color_scheme.dart';
import 'package:trictux_chatroom/firebase_options.dart';
import 'package:trictux_chatroom/hive_local_database/bot_dataset.dart';
import 'package:trictux_chatroom/pages/all_charts.dart';

void main() async {
    Gemini.init(apiKey: Gemini_Api_Key);
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    var directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
    Hive.registerAdapter(BotAdaptor());
    await Hive.openBox<Bot>('chat');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: mode,
      home: const AuthGate(),
    );
  }
}