import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key key,
    @required this.roomId,
  })  : assert(roomId != null),
        super(key: key);

  final String roomId;

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    FirebaseChatCore.instance.updateMessageWithPreviewData(
      message.id,
      previewData,
      roomId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: StreamBuilder<List<types.Message>>(
        stream: FirebaseChatCore.instance.messages(roomId),
        initialData: [],
        builder: (context, snapshot) {
          return Chat(
            messages: snapshot.data ?? [],
            onPreviewDataFetched: _onPreviewDataFetched,
            onSendPressed: (message) => FirebaseChatCore.instance.sendMessage(
              message,
              roomId,
            ),
            user: types.User(
              firstName: 'Alex',
              id: FirebaseChatCore.instance.firebaseUser.uid,
              lastName: 'Demchenko',
            ),
          );
        },
      ),
    );
  }
}
