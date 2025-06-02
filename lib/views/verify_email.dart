import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

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
              context.read<AuthBloc>().add(
                const AuthEventSendEmailVerification()
                );
            }, 
            child: const Text('Resend email verification'),),
            TextButton(
              onPressed: () async {
               context.read<AuthBloc>().add(
                const AuthEventLogOut()
               );
              }, 
              child: const Text('Restart'),
              ),
          ],
        ),
    );
  }
}