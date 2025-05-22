import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute, 
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


