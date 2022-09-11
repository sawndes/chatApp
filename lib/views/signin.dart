import 'package:flutter/material.dart';
import 'package:messenger_clone/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messenger"),
      ),
      body: Center(
        child: GestureDetector(
          onTap: (() {
            AuthMethods().signInWithGoogle(context);
          }),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffDB4437),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              "Sign in with google",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
