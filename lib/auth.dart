import 'package:flutteresp32/login.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'SignUp.dart';

class auth extends StatefulWidget {

  @override
  State<auth> createState() => _authState();
}

class _authState extends State<auth> {
  bool islogin = true;

  @override
  Widget build(BuildContext context) =>
     islogin ? login(onClickedSignUp: toggle) :
      SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() => islogin = !islogin);
}