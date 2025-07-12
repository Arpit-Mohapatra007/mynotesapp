import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
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
      backgroundColor: Colors.grey,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: const Color.fromARGB(0, 158, 158, 158).withOpacity(0.3),
                        spreadRadius: 10,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
      child:  SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // adjusts with keyboard
                  ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mail_rounded,
                color: Colors.red,
                size: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(context.loc.verify_email_view_prompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                ),
              ),
              ElevatedButton(onPressed: () async {
                context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification()
                  );
              }, 
              child:  Text(context.loc.verify_email_send_email_verification),),
              ElevatedButton(
                onPressed: () async {
                 context.read<AuthBloc>().add(
                  const AuthEventLogOut()
                 );
                }, 
                child:  Text(context.loc.restart),
                ),
            ],
          ),
      ),
    )
    )
    )
    )
    );
  }
}