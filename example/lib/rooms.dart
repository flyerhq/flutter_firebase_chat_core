import 'package:example/chat.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class RoomsPage extends StatefulWidget {
  RoomsPage({Key key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  bool _error = false;
  bool _initialized = false;
  auth.User _user;

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      auth.FirebaseAuth.instance.authStateChanges().listen((auth.User user) {
        setState(() {
          _user = user;
        });
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void login() async {
    try {
      await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "dexter.crona@gmail.com",
        password: "Qawsed1-",
      );
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  void logout() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _user != null ? () {} : null,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _user != null ? logout : null,
        ),
        title: const Text('Rooms'),
      ),
      body: _user != null
          ? StreamBuilder<List<Room>>(
              stream: FirebaseChatCore.instance.rooms(),
              initialData: [],
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data.length == 0) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                      bottom: 200,
                    ),
                    child: const Text('No rooms'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final Room room = snapshot.data[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              roomId: room.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              margin: EdgeInsets.only(
                                right: 16,
                              ),
                              width: 40,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                child: Image.network(room.imageUrl),
                              ),
                            ),
                            Text(room.name),
                          ],
                        ),
                      ),
                    );
                  },
                );
              })
          : Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not authenticated'),
                  FlatButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
    );
  }
}
