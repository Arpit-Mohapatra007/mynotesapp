import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email=TextEditingController();
    _password=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'), backgroundColor: Color.fromARGB(239, 3, 3, 187),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
          builder:(context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:
                return Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter Email',
                      ),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Enter Password',
                      ),
                    ),
                    TextButton(onPressed:() async{
                      final email=_email.text;
                      final password=_password.text;
                      try{
                        final userCredentials= await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, 
                        password: password
                        );
                        print(userCredentials);
                      } on FirebaseAuthException catch(e){
                        if(e.code=='weak-password'){
                          print('Weak Password!!');
                        }
                        else if(e.code=='email-already-in-use'){
                          print('Email already in use buddy !!');
                        }
                        else if(e.code=='invalid-email'){
                          print('Invalid email dude !!');
                        }
                      }
                      
                    }, child: const Text('Register'),),
                  ],
                );
                default:
                  return const Text('Loading....');
        }

          },
        )
    );
  }

}

