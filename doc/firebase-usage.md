---
id: firebase-usage
title: Usage
---

As mentioned in [How it works?](firebase-overview#how-it-works), you will need to register a user using [Firebase Authentication](https://firebase.google.com/docs/auth). If you are using Firebase Authentication as your auth provider you don't need to do anything except calling `FirebaseChatCore.instance.createUserInFirestore` after registration.

```dart
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

await FirebaseChatCore.instance.createUserInFirestore(
  types.User(
    avatarUrl: 'https://i.pravatar.cc/300',
    firstName: 'Alex',
    id: credential.user!.uid, // UID from Firebase Authentication
    lastName: 'Demchenko',
  ),
);
```

You can provide values like `avatarUrl`, `firstName` and `lastName` if you're planning to have a screen with all users available for chat. The `id` is the only required field and you **need to** use the `uid` you get from the Firebase Authentication after you register a user. If you don't use Firebase for authentication, you can register a user using your custom `JWT` token, then call `FirebaseChatCore.instance.createUserInFirestore` as described above.

Aside from registration, you will need to log users in when appropriate, using available methods from Firebase Authentication, including the custom `JWT` token.

## Firebase Chat with custom backend

This wasn't verified on production, but if you have your backend and want to use Firebase only for the chat functionality, you can register/login users using custom `JWT` token as described above and save received `uid` to your `users` table. Then you can have a screen with all users from your `users` table where each of them will have an assigned `uid` that will be used to start a chat. Or maybe you will have a search mechanism implemented on your backend, or you don't show users at all, just a button to start a chat with a random person, you still have access to that `uid`.

Alternatively, you can use the `FirebaseChatCore.instance.users()` stream which will return all registered users with avatars and names.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          // ...
        },
      ),
    );
  }
}
```

## Starting a chat

When you have access to that `uid` or you have the whole `User` class from the `FirebaseChatCore.instance.users()` stream, you can call either `createRoom` or `createGroupRoom`. For the group, you will need to additionally provide a name and an optional image.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  // Create a user with an ID of UID if you don't use `FirebaseChatCore.instance.users()` stream
  void _handlePressed(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    // Navigate to the Chat screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          // ...
        },
      ),
    );
  }
}
```

## Rooms

To render user's rooms you use the `FirebaseChatCore.instance.rooms()` stream. `Room` class will have the name and image URL taken either from provided ones for the group or set to the other person's avatar URL and name. See [Security Rules](firebase-rules) for more info about rooms filtering.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(),
        initialData: const [],
        builder: (context, snapshot) {
          // ...
        },
      ),
    );
  }
}
```

## Messages

`FirebaseChatCore.instance.messages` stream will give you access to all messages in the specified room.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<types.Message>>(
        stream: FirebaseChatCore.instance.messages(widget.roomId),
        initialData: const [],
        builder: (context, snapshot) {
          // ...
        },
      ),
    );
  }
}
```

If you use Flyer Chat UI you can just pass `snapshot.data ?? []` to the `messages` parameter of the Chat widget. See the [example](https://github.com/flyerhq/flutter_firebase_chat_core/blob/main/example/lib/chat.dart).

### Send a message

To send a message use `FirebaseChatCore.instance.sendMessage`, it accepts 2 parameters:

* Any partial message. Click [here](/chat-ui/types) to learn more about the types or check the [API reference](https://pub.dev/documentation/flutter_chat_types/latest/index.html). You provide a partial message because Firebase will set fields like `authorId`, `id` and `timestamp` automatically.
* Room ID.

### Update the message

To update the message use `FirebaseChatCore.instance.updateMessage`, it accepts 2 parameters:

* Any message. Click [here](/chat-ui/types) to learn more about the types or check the [API reference](https://pub.dev/documentation/flutter_chat_types/latest/index.html). Use a message you get from the `FirebaseChatCore.instance.messages` stream, update it and send as this parameter.
* Room ID.

## `firebaseUser`

`FirebaseChatCore.instance.firebaseUser` is a shortcut you can use to see which user is currently logged in through Firebase Authentication. The returned type comes from the Firebase library and **it is not the same `User` as from the `flutter_chat_types` package**.

:::note

`firebaseUser` will not be updated dynamically, if you are looking for that feature, use `FirebaseAuth.instance.authStateChanges()` from the [Authentication](https://firebase.flutter.dev/docs/auth/overview) plugin.

:::
