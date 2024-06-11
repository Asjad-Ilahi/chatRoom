import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trictux_chatroom/auth/firebase_auth.dart';
import 'package:trictux_chatroom/chatting/chat_services.dart';
import 'package:trictux_chatroom/component/chat_bubble.dart';
import 'package:trictux_chatroom/component/my_text_field.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const ChatPage({Key? key, required this.receiverEmail, required this.receiverId})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  ValueNotifier<String?> repliedMessageNotifier = ValueNotifier<String?>(null);

  final Authentication auth = Authentication();
  final ChatService chat = ChatService();
  final ScrollController controller = ScrollController();
  FocusNode myNode = FocusNode();

  @override
  void initState() {
    super.initState();

    myNode.addListener(() {
      if (myNode.hasFocus) {
        Future.delayed(const Duration(microseconds: 500), () => scrollDown());
      }
    });
    Future.delayed(const Duration(microseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myNode.dispose();
    messageController.dispose();
    repliedMessageNotifier.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String messageText = messageController.text;
      messageController.clear();
      await chat.sendMessage(widget.receiverId, messageText, repliedMessage: repliedMessageNotifier.value);
      repliedMessageNotifier.value = null; // Clear the replied message after sending
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Expanded(child: buildMessageList()),
          ValueListenableBuilder<String?>(
            valueListenable: repliedMessageNotifier,
            builder: (context, repliedMessage, child) {
              return repliedMessage != null ? buildRepliedMessagePreview(repliedMessage) : SizedBox.shrink();
            },
          ),
          userInput(),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    String senderId = auth.currentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: chat.getMessage(widget.receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "Error",
            style: TextStyle(color: Colors.white),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            "Loading..",
            style: TextStyle(color: Colors.white),
          );
        }

        // Scroll down when new data is received
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());

        return ListView(
          controller: controller,
          children: snapshot.data!.docs.map((doc) => buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderId"] == auth.currentUser()!.uid;
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onLongPress: () {
        if (isCurrentUser) {
          _showDeleteConfirmation(context, doc.id);
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          repliedMessageNotifier.value = data["message"];
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              alignment: alignment,
              child: ChatButton(
                message: data["message"],
                isCurrentUser: isCurrentUser,
                repliedMessage: data["repliedMessage"],
                timestamp: (data["timestamp"] as Timestamp).toDate(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteMessage(messageId);
                Navigator.of(context).pop();
                _refreshMessages();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    await chat.deleteMessage(messageId, widget.receiverId, auth.currentUser()!.uid);
  }

  void _refreshMessages() {
    // No need to use setState, the StreamBuilder will automatically refresh
  }

  Widget userInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: "Message...",
              obscure: false,
              controller: messageController,
              focusNode: myNode,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.purpleAccent.shade400,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRepliedMessagePreview(String repliedMessage) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey.shade200,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Row(
          children: [
            Expanded(
              child: Text(
                repliedMessage,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                repliedMessageNotifier.value = null; // Clear the replied message preview
              },
            ),
          ],
        ),
      ),
    );
  }
}
