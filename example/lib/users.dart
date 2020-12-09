import 'package:example/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UsersPage extends StatelessWidget {
  void _handlePressed(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).push(
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
        title: const Text('Users'),
      ),
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.length == 0) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('No users'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              final types.User user = snapshot.data[index];

              return GestureDetector(
                onTap: () {
                  _handlePressed(user, context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(
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
                      Text('${user.firstName} ${user.lastName}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
