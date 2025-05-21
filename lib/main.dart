import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email.dart';
import 'dart:developer'as devtools show log;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter-Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 4, 0)),
      ),
      home: const HomePage(),
      routes: {
        '/login/':(context)=> const LoginView(),
        '/register/':(context)=> const RegisterView(),
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

    @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
          builder:(context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:
              final user =FirebaseAuth.instance.currentUser;
              if(user!=null){
                if (user.emailVerified) {
                  return const NotesView();
                }else{
                  return const VerifyEmailView();
                }
              }else{
                return const LoginView();
              }
                default:
                  return const CircularProgressIndicator();
        }

          },
        );
  }

}
enum MenuAction{logout}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        backgroundColor: Color.fromARGB(239, 12, 12, 238),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value){
                
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login/', 
                  (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) {
              return const[
                PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('LogOut'),
                ),
              ];
            },
          ),
        ],
      ),
      body: const Text('Hello World!!'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog(
    context: context, 
    builder: (context){
      return AlertDialog(
        title: const Text('SignOut'),
        content: const Text('Are you sure want to Sign Out ?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancle'),
            ),
            TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            },
            child: const Text('Log Out'),
            )
        ],
      );
    },
    ).then(
      (value) => value??false
      );
}