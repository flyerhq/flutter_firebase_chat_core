import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loggingIn = false;
  FocusNode _focusNode;
  String _password = 'Qawsed1-';
  TextEditingController _passwordController;
  String _username =
      Platform.isIOS ? 'dexter.crona@gmail.com' : 'ofelia84@hotmail.com';
  TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _passwordController = TextEditingController(text: _password);
    _usernameController = TextEditingController(text: _username);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loggingIn = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      setState(() {
        _loggingIn = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  labelText: 'Email',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => _usernameController.clear(),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: () {
                  _focusNode.requestFocus();
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
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _passwordController.clear(),
                    ),
                  ),
                  focusNode: _focusNode,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  onEditingComplete: _login,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                ),
              ),
              FlatButton(
                onPressed: _loggingIn ? null : _login,
                child: const Text('Login'),
              ),
              FlatButton(
                onPressed: _loggingIn ? null : () {},
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
