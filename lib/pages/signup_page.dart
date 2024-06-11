import 'package:flutter/material.dart';
import 'package:trictux_chatroom/auth/Firebase_auth.dart';
import 'package:trictux_chatroom/component/my_text_field.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key, this.ontap});

  final TextEditingController eController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController cpController = TextEditingController();
  final void Function()? ontap;

  void signUp(BuildContext context) async {
    final authSurvice = Authentication();
    if (pController.text == cpController.text) {
      try {
        await authSurvice.signUpEandP(eController.text, pController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(e.toString()),
              ),);
      }
    } else {
      showDialog(
          context: context,
          builder: (context) =>
          const AlertDialog(
            title: Text("Password Don't Match"),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      body: Center(
        child: SingleChildScrollView( // Wrap with SingleChildScrollView
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
              MyTextField(
                hintText: 'Email', obscure: false, controller: eController,),
              const SizedBox(height: 20,),
              MyTextField(
                hintText: 'Password', obscure: true, controller: pController,),
              const SizedBox(height: 20),
              MyTextField(hintText: 'Confirm Password',
                obscure: true,
                controller: cpController,),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme
                              .of(context)
                              .colorScheme
                              .primary),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => signUp(context),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .inversePrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member? ', style: TextStyle(color: Theme
                      .of(context)
                      .colorScheme
                      .inversePrimary),),
                  GestureDetector(
                    onTap: ontap,
                    child: Text(
                      'Click Here!',
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .inversePrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme
                            .of(context)
                            .colorScheme
                            .inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}