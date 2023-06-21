import 'package:flutter/material.dart';
import 'package:flutteresp32/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:email_validator/email_validator.dart';

import 'Utils.dart';


class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({Key? key, required this.onClickedSignIn,}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidget();
}

class _SignUpWidget extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40,),
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText : "Email"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) =>
            email != null && !EmailValidator.validate(email) ?
            "Enter a valid email" : null ,
          ),
          SizedBox(height: 4,),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText : "Password"),
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
            value != null && value.length < 6 ?
            "Enter min. 6 characters" : null ,
          ),
          SizedBox(height: 20,),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ), onPressed: (){
                signUp();
          },
              icon: Icon(Icons.arrow_forward) ,label: Text(
            "Sign Up", style: TextStyle(fontSize: 24),
          ),),
          SizedBox(height: 24,),
          RichText(text: TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 16),
            text: "Already have an account? ",
            children: [
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignIn,
                text: "Log In",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.secondary,
                )
              )
            ],
          ))
        ],
      ),
    ),
    );
  }

  Future signUp() async{
    final isvalid = formKey.currentState!.validate();
    if(!isvalid) return;

    showDialog(context: context,barrierDismissible: false ,
        builder: (context) => Center(child: CircularProgressIndicator(),)
    );
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch(e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}




