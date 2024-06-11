import 'package:flutter/material.dart';
import 'package:trictux_chatroom/auth/firebase_auth.dart';
import 'package:trictux_chatroom/component/my_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key,this.ontap});
  final TextEditingController eController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final void Function()? ontap;

  void login(BuildContext context) async{
    final authService = Authentication();
    try{
      await authService.signInEandP(eController.text, pController.text);
    }catch (e){
      showDialog(
          context: context,
          builder: (context)=>AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(e.toString()),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset('lib/assets/logos/logo.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 50,),
            MyTextField(hintText: 'Email', obscure: false,controller: eController,),
            const SizedBox(height: 20,),
            MyTextField(hintText: 'Password',obscure: true,controller: pController,),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: TextButton(onPressed: ()=>login(context),
                        child: Text('Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.inversePrimary
                        ),
                        )),
                  ),
                ),
              ],),
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member? ', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                  GestureDetector(
                    onTap: ontap,
                    child: Text('Register Now!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
}
