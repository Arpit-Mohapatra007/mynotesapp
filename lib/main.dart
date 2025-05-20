import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 4, 0)),
      ),
      home: const HomePage(),
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'), backgroundColor: Color.fromARGB(239, 3, 3, 187),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
          builder:(context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:
              final user =FirebaseAuth.instance.currentUser;
              if(user?.emailVerified ?? false){
                print('You are not a verified user');
              } else{
                print('You need to verify you email!!');
              }
                return const Text('Done!!');
                default:
                  return const Text('Loading....');
        }

          },
        )
    );
  }

}