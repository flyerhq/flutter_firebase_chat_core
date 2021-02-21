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

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key key,
    @required this.roomId,
  })  : assert(roomId != null),
        super(key: key);

  final String roomId;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isAttachmentUploading = false;

  void _handleAtachmentPress() {
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
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showImagePicker();
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Open image picker"),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Cancel"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.roomId);
  }

  void _onSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message.asThird(),
      widget.roomId,
    );
  }

  void _openFile(types.FileMessage message) async {
    String localPath = message.uri;

    if (message.uri.startsWith('http')) {
      final client = new http.Client();
      final request = await client.get(Uri.parse(message.uri));
      final bytes = request.bodyBytes;
      final documentsDir = (await getApplicationDocumentsDirectory()).path;
      localPath = '$documentsDir/${message.fileName}';

      if (!File(localPath).existsSync()) {
        final file = new File(localPath);
        await file.writeAsBytes(bytes);
      }
    }

    await OpenFile.open(localPath);
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  void _showFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final filePath = result.files.single.path;
      final fileName = result.files.single.name;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(fileName);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          fileName: result.files.single.name,
          mimeType: lookupMimeType(result.files.single.path),
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(
          message.asFirst(),
          widget.roomId,
        );
        _setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        _setAttachmentUploading(false);
        print(e);
      }
    } else {
      // User canceled the picker
    }
  }

  void _showImagePicker() async {
    final result = await ImagePicker().getImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final imageName = result.path.split('/').last;

      try {
        final reference = FirebaseStorage.instance.ref(imageName);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          imageName: imageName,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message.asSecond(),
          widget.roomId,
        );
        _setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        _setAttachmentUploading(false);
        print(e);
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: StreamBuilder<List<types.Message>>(
        stream: FirebaseChatCore.instance.messages(widget.roomId),
        initialData: [],
        builder: (context, snapshot) {
          return Chat(
            isAttachmentUploading: _isAttachmentUploading,
            messages: snapshot.data ?? [],
            onAttachmentPressed: _handleAtachmentPress,
            onFilePressed: _openFile,
            onPreviewDataFetched: _onPreviewDataFetched,
            onSendPressed: _onSendPressed,
            user: types.User(id: FirebaseChatCore.instance.firebaseUser.uid),
          );
        },
      ),
    );
  }
}
