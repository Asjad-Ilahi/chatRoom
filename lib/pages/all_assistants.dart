import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trictux_chatroom/chatbot/bot_box.dart';
import 'package:trictux_chatroom/chatbot/bot_home_page.dart';
import 'package:trictux_chatroom/hive_local_database/bot_dataset.dart';

class AllChatBots extends StatefulWidget {
  const AllChatBots({super.key});

  @override
  State<AllChatBots> createState() => _AllChatBotsState();
}

class _AllChatBotsState extends State<AllChatBots> {
  final nameController = TextEditingController();
  final instructionsController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'Chatbots',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
        leading:
        IconButton(
          onPressed: () {
            setState(() {
              searchQuery = '';
            });
          },
          icon: Icon(
            Icons.refresh,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ValueListenableBuilder<Box<Bot>>(
        valueListenable: ChatBotBox.getData().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<Bot>();

          if (searchQuery.isNotEmpty) {
            data = data
                .where((bot) =>
                bot.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          removeChatBot(context, data[index]);
                        },
                        icon: Icons.delete,
                        backgroundColor: Colors.red.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          editPopUP(
                            context,
                            data[index],
                            data[index].name,
                            data[index].instruction,
                          );
                        },
                        icon: Icons.edit_note_rounded,
                        backgroundColor: Colors.blue.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        child: FaIcon(
                          FontAwesomeIcons.robot,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      title: Text(
                        data[index].name,
                        style: TextStyle(
                            fontSize: 19,
                            color: Theme.of(context).colorScheme.inversePrimary),
                      ),
                      subtitle: Text(
                        "Chat...",
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.inversePrimary),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatbotPage(
                              botName: data[index].name,
                              botInstructions: data[index].instruction,
                            ),
                          ),
                        );
                      },
                      trailing: InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popMessage();
        },
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void removeChatBot(BuildContext context, Bot chatBot) async {
    final box = ChatBotBox.getData();
    final key = box.keys.firstWhere((k) => box.get(k) == chatBot);
    await box.delete(key);
  }

  Future<void> editPopUP(
      BuildContext context, Bot chatBot, String name, String instructions) async {
    nameController.text = name;
    instructionsController.text = instructions;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit ChatBot'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name..',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    hintText: 'Instructions..',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                nameController.clear();
                instructionsController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shadowColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 70),
            ElevatedButton(
              onPressed: () {
                if (_validateFields()!) {
                  chatBot.name = nameController.text.toString();
                  chatBot.instruction = instructionsController.text.toString();
                  chatBot.save();
                  nameController.clear();
                  instructionsController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shadowColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool? _validateFields() {
    String name = nameController.text.toString();
    String instructions = instructionsController.text.toString();

    if (name.isEmpty || instructions.isEmpty) {
      _showValidationError('Please fill all fields');
      return false;
    }

    if (name.length < 2 || name.length > 19) {
      _showValidationError('Name should be between 2 and 19 characters');
      return false;
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
      _showValidationError('Name should contain only letters');
      return false;
    }

    return true;
  }

  Future<void> popMessage() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add ChatBot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name..',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    hintText: 'Instructions..',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                nameController.clear();
                instructionsController.clear();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shadowColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 50),
            ElevatedButton(
              onPressed: () {
                if (_validateFields()!) {
                  Navigator.pop(context);
                  final newBot = Bot(
                    name: nameController.text,
                    instruction: instructionsController.text,
                  );
                  final box = ChatBotBox.getData();
                  box.add(newBot);
                  nameController.clear();
                  instructionsController.clear();
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shadowColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shadowColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search ChatBot'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter ChatBot name...',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchQuery = searchController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shadowColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
