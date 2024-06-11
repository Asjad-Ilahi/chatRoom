import 'package:flutter/material.dart';
import 'package:trictux_chatroom/pages/login_page.dart';
import 'package:trictux_chatroom/pages/signup_page.dart';

class LoginToRegister extends StatefulWidget {
  const LoginToRegister({super.key});

  @override
  State<LoginToRegister> createState() => _LoginToRegisterState();
}

class _LoginToRegisterState extends State<LoginToRegister> {
  bool isLoginPage=true;

  void changePage(){
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(isLoginPage){
      return LoginPage(
        ontap: changePage,
      );
    }else{
      return SignUpPage(
        ontap: changePage,
      );
    }
  }
}
