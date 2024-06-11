import 'package:flutter/material.dart';
import 'package:trictux_chatroom/auth/firebase_auth.dart';
import 'package:trictux_chatroom/pages/setting_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});


  void logout(){
    final auth = Authentication();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,

      child: Column(
        children: [
          DrawerHeader(
            child: SizedBox(
            height: 80,
            width: 80,
            child: Image.asset('lib/assets/logos/logo.png',
              fit: BoxFit.contain,
            ),
          ),),
          const SizedBox(height: 50,),
          Padding(padding: const EdgeInsets.only(left: 20),
            child: ListTile(
              title: const Text("S E T T I N G"),
              leading: const Icon(Icons.settings),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context, MaterialPageRoute(builder: (context)=>const SettingPage())
                );
              },
            ),
          ),
          const SizedBox(height: 20,),
          Padding(padding: const EdgeInsets.only(left: 20),
          child: ListTile(
            title: const Text("L O G O U T"),
            leading: const Icon(Icons.logout_rounded),
            onTap: (){
              Navigator.pop(context);
              logout();
            },
          ),
          ),
        ],
      ),
    );
  }
}
