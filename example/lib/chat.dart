import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key key,
    this.roomId,
  })  : assert(roomId != null),
        super(key: key);

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: StreamBuilder(
        stream: FirebaseChatCore.instance.messages(roomId),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Chat(
              messages: snapshot.data,
              onSendPressed: (message) {},
              user: types.User(
                firstName: 'Alex',
                id: FirebaseChatCore.instance.firebaseUser.uid,
                lastName: 'Demchenko',
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
