// import 'package:example/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'chat.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  void _handleOnPress(types.User otherUser, BuildContext context) async {
    final room =
        await FirebaseChatCore.instance.createRoom(otherUser: otherUser);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          roomId: room.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: FirebaseChatCore.instance.firebaseUser != null
          ? StreamBuilder<List<types.User>>(
              stream: FirebaseChatCore.instance.users(),
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
                    final types.User user = snapshot.data[index];

                    return GestureDetector(
                      onTap: () {
                        _handleOnPress(user, context);
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
                                child: Image.network(user.avatarUrl),
                              ),
                            ),
                            Text([user.firstName, user.lastName].join(' ')),
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
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => LoginPage(),
                      //   ),
                      // );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
    );
  }
}
