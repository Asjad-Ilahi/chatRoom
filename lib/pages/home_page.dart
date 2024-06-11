import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trictux_chatroom/auth/firebase_auth.dart';
import 'package:trictux_chatroom/chatting/chat_services.dart';
import 'package:trictux_chatroom/component/custom_drawer.dart';
import 'package:trictux_chatroom/component/user_tile.dart';
import 'package:trictux_chatroom/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService chatService = ChatService();
  final Authentication auth = Authentication();
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> recentChats = [];
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    prefs = await SharedPreferences.getInstance();
    final recentChatIds = prefs?.getStringList('recentChats') ?? [];

    final usersStream = chatService.getUsers();
    final users = await usersStream.first;

    setState(() {
      allUsers = users;
      recentChats = users.where((user) => recentChatIds.contains(user['uid'])).toList();
    });
  }

  void _addRecentChat(String uid) async {
    final recentChatIds = prefs?.getStringList('recentChats') ?? [];
    if (!recentChatIds.contains(uid)) {
      recentChatIds.add(uid);
      await prefs?.setStringList('recentChats', recentChatIds);
      setState(() {
        recentChats = allUsers.where((user) => recentChatIds.contains(user['uid'])).toList();
      });
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(allUsers: allUsers, addRecentChat: _addRecentChat);
      },
    );
  }

  void _clearChat(String uid) {
    setState(() {
      recentChats.removeWhere((user) => user['uid'] == uid);
    });
    List<String> recentChatIds = prefs?.getStringList('recentChats') ?? [];
    recentChatIds.remove(uid);
    prefs?.setStringList('recentChats', recentChatIds);
  }

  void _deleteChat(String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _clearChat(uid);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.inversePrimary),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'Home',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.inversePrimary),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                if (recentChats.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                  ),
                ...recentChats.map((userData) => myStreamBuilderItem(userData, context)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget myStreamBuilderItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != auth.currentUser()!.email) {
      return StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: chatService.getUnreadMessages(userData['uid']),
        builder: (context, snapshot) {
          int unreadCount = 0;
          if (snapshot.hasData) {
            unreadCount = snapshot.data!.length;
          }
          String messageText = unreadCount > 4
              ? 'You have received more than 4 messages'
              : 'You have received $unreadCount new messages';

          return UserTile(
            text: userData["email"],
            subTitle: "${unreadCount > 0 ? messageText : ''}",
            onTap: () {
              _addRecentChat(userData["uid"]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverId: userData["uid"],
                    receiverEmail: userData["email"],
                  ),
                ),
              );
            },
            onDelete: () {
              _deleteChat(userData["uid"]);
            },
          );
        },
      );
    } else {
      return Container();
    }
  }
}

class SearchDialog extends StatefulWidget {
  final List<Map<String, dynamic>> allUsers;
  final Function(String) addRecentChat;

  const SearchDialog({required this.allUsers, required this.addRecentChat});

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = [];
  }

  void _filterUsers(String query) {
    final filtered = widget.allUsers.where((user) {
      final emailLower = user['email'].toLowerCase();
      final queryLower = query.toLowerCase();
      return emailLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      filteredUsers = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for users',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
          ),
        ),
        onChanged: _filterUsers,
      ),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (BuildContext context, int index) {
            final userData = filteredUsers[index];
            return ListTile(
              title: Text(userData['email']),
              onTap: () {
                widget.addRecentChat(userData['uid']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverId: userData['uid'],
                      receiverEmail: userData['email'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
