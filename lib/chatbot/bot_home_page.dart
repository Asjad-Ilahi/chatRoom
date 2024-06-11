import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatbotPage extends StatefulWidget {
  final String botName;
  final String botInstructions;

  const ChatbotPage({super.key, required this.botName, required this.botInstructions});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final Gemini gemini = Gemini.instance;
  late ChatUser curUser;
  late ChatUser geminiUser;
  List<ChatMessage> messages = [];

@override
  void initState() {
  curUser = ChatUser(id: '0', firstName: 'user');
  geminiUser = ChatUser(id: '1', firstName: widget.botName, profileImage: 'lib/assets/logos/logo.png');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.botName,
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: DashChat(
        inputOptions: InputOptions(
          trailing: [
            IconButton(
              onPressed: _sendMediaMessage,
              icon: Icon(
                Icons.image_rounded,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            )
          ],
        ),
        currentUser: curUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  void _sendMessage(ChatMessage message) {
    setState(() {
      messages = [message, ...messages];
    });
    try {
      String question = message.text;
      question += ". ${widget.botInstructions}";
      List<Uint8List>? images;
      if (message.medias?.isNotEmpty ?? false) {
        images = [File(message.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold("", (previous, current) => "$previous${current.text}") ?? "";
          ChatMessage chatMessage = ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: response);
          setState(() {
            messages = [chatMessage, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage message = ChatMessage(
        user: curUser,
        createdAt: DateTime.now(),
        text: "Analyze the picture according to instruction: ${widget.botInstructions}",
        medias: [ChatMedia(url: file.path, fileName: "", type: MediaType.image)],
      );
      _sendMessage(message);
    }
  }
}
