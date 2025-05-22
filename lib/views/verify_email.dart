import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Color.fromARGB(229, 16, 16, 251),
      ),
      body: Column(
          children: [
            const Text("We've sent you an email verification, Please verify your account."),
            const Text("If you haven't recieved a verification email yet press below:"),
            TextButton(onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            }, 
            child: const Text('Resend email verification'),),
            TextButton(
              onPressed: () async {
               await AuthService.firebase().logOut();
               Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route)=>false);
              }, 
              child: const Text('Restart'),
              ),
          ],
        ),
    );
  }
}