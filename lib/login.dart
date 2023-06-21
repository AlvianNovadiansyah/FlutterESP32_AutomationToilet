import 'package:flutter/material.dart';
import 'package:flutteresp32/Utils.dart';
import 'package:flutteresp32/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutteresp32/forgotpassword.dart';


class login extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const login({Key? key, required this.onClickedSignUp,}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40,),
          TextField(
            controller: emailController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText : "Email"),
          ),
          SizedBox(height: 4,),
          TextField(
            controller: passwordController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText : "Password"),
            obscureText: true,
          ),
          SizedBox(height: 20,),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ), onPressed: (){
                signIn();
          },
              icon: Icon(Icons.lock_open_outlined) ,label: Text(
            "Sign In", style: TextStyle(fontSize: 24),
          ),),
          SizedBox(height: 24,),
          GestureDetector(
            child: Text(
              "Forgot Password", style: TextStyle(
              decoration: TextDecoration.underline,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20,
            ),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => forgotPasswordPage()
            )),
          ),
          SizedBox(height: 15,),
          RichText(text: TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 16),
            text: "No account? ",
            children: [
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignUp,
                text: "Sign Up",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.secondary,
                )
              )
            ],
          ))
        ],
      ),
    );
  }

  Future signIn() async{
    showDialog(context: context,barrierDismissible: false ,
        builder: (context) => Center(child: CircularProgressIndicator(),)
    );
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch(e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}




