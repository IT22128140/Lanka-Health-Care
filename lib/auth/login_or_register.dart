import 'package:lanka_health_care/pages/login_page.dart';
import 'package:lanka_health_care/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initially show login page
  int showLoginPage = 0;

  //toggle between signin and signup page
  void togglePages(int i) {
    setState(() {
      showLoginPage = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage == 0) {
      return LoginPage(onTap: () => togglePages(1));
    } else {
      return RegisterPage(onTap: () => togglePages(0));
    }
  }
}
