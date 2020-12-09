import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loggingIn = false;
  String _password = 'Qawsed1-';
  String _username =
      Platform.isIOS ? 'dexter.crona@gmail.com' : 'ofelia84@hotmail.com';

  final _focus = FocusNode();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _loggingIn = true;
    });

    try {
      await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _node = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            children: [
              TextField(
                autocorrect: false,
                autofillHints: _loggingIn ? null : [AutofillHints.email],
                autofocus: true,
                controller: _usernameController..text = _username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  labelText: 'Email',
                  hintText: 'Email',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => _usernameController.clear(),
                  ),
                ),
                enabled: !_loggingIn,
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: () => {
                  _node.requestFocus(_focus),
                },
                readOnly: _loggingIn,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  autocorrect: false,
                  autofillHints: _loggingIn ? null : [AutofillHints.password],
                  controller: _passwordController..text = _password,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    labelText: 'Password',
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _passwordController.clear(),
                    ),
                  ),
                  enabled: !_loggingIn,
                  focusNode: _focus,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  onSubmitted: (_) => _node.unfocus(),
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                ),
              ),
              FlatButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
              FlatButton(
                onPressed: () {},
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
