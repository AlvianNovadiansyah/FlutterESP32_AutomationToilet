import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutteresp32/Utils.dart';
import 'package:flutter/material.dart';

class forgotPasswordPage extends StatefulWidget {
  const forgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<forgotPasswordPage> createState() => _forgotPasswordPageState();
}

class _forgotPasswordPageState extends State<forgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Reset Password"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Receive an email to\nreset yout password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),),
              SizedBox(height: 20,),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: "Email"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                email != null && !EmailValidator.validate(email) ?
                "Enter a valid email" : null,
              ),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ), onPressed: () {
                ResetPassword();
              },
                icon: Icon(Icons.mail_outline), label: Text(
                "Reset Password", style: TextStyle(fontSize: 24),
              ),),
            ],
          ),
        ),
      ),
    );
  }

    Future ResetPassword() async {

      showDialog(context: context,barrierDismissible: false ,
          builder: (context) => Center(child: CircularProgressIndicator(),)
      );

      try{
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: emailController.text.trim());

        Utils.showSnackBar("Password Reset Email Sent");
        Navigator.of(context).popUntil((route) => route.isFirst);
      } on FirebaseAuthException catch(e){
        print(e);

        Utils.showSnackBar(e.message);
      }
    }
  }