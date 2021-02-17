import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:union/union.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key key,
    @required this.roomId,
  })  : assert(roomId != null),
        super(key: key);

  final String roomId;

  void _handleAtachmentPress(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showFilePicker();
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Open file picker"),
                  )),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showImagePicker();
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Open image picker"),
                  )),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Cancel"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _openFile(types.FileMessage message) async {
    String localPath = message.url;

    if (message.url.startsWith('http')) {
      final client = new http.Client();
      var request = await client.get(Uri.parse(message.url));
      var bytes = request.bodyBytes;
      final documentsDir = (await getApplicationDocumentsDirectory()).path;
      localPath = '$documentsDir/${message.fileName}';

      if (!File(localPath).existsSync()) {
        final file = new File(localPath);
        await file.writeAsBytes(bytes);
      }
    }

    await OpenFile.open(localPath);
  }

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

  void _onSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message.asThird(),
      roomId,
    );
  }

  void _showFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final filePath = result.files.single.path;
      final fileName = result.files.single.name;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(fileName);
        await reference.putFile(file);
        final url = await reference.getDownloadURL();

        final message = types.PartialFile(
          fileName: result.files.single.name,
          mimeType: lookupMimeType(result.files.single.path),
          size: result.files.single.size,
          url: url,
        );

        FirebaseChatCore.instance.sendMessage(
          message.asFirst(),
          roomId,
        );
      } on FirebaseException catch (e) {
        print(e);
      }
    } else {
      // User canceled the picker
    }
  }

  void _showImagePicker() async {
    final result = await ImagePicker().getImage(source: ImageSource.gallery);
    if (result != null) {
      final size = File(result.path).lengthSync();
      final extension = result.path.split('.').last;
      final imageName = 'image.$extension';
      final file = File(result.path);

      try {
        final reference = FirebaseStorage.instance.ref(imageName);
        await reference.putFile(file);
        final url = await reference.getDownloadURL();

        final message = types.PartialImage(
          imageName: imageName,
          size: size,
          url: url,
        );

        FirebaseChatCore.instance.sendMessage(
          message.asSecond(),
          roomId,
        );
      } on FirebaseException catch (e) {
        print(e);
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = types.User(
      firstName: 'Alex',
      id: FirebaseChatCore.instance.firebaseUser.uid,
      lastName: 'Demchenko',
    );

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
            onAttachmentPressed: () {
              _handleAtachmentPress(context);
            },
            onFilePressed: _openFile,
            onPreviewDataFetched: _onPreviewDataFetched,
            onSendPressed: _onSendPressed,
            user: _user,
          );
        },
      ),
    );
  }
}
