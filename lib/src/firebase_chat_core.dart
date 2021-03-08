import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import './models/room.dart';
import 'util.dart';

class FirebaseChatCore {
  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseUser = user;
    });
  }

  User? firebaseUser = FirebaseAuth.instance.currentUser;

  static final FirebaseChatCore instance =
      FirebaseChatCore._privateConstructor();

  Future<Room> createGroupRoom({
    required String imageUrl,
    required String name,
    required List<types.User> users,
  }) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final currentUser = await fetchUser(firebaseUser!.uid);
    final roomUsers = [currentUser] + users;

    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'imageUrl': imageUrl,
      'isGroup': true,
      'name': name,
      'userIds': roomUsers.map((u) => u.id).toList(),
    });

    return Room(
      id: room.id,
      imageUrl: imageUrl,
      isGroup: true,
      name: name,
      users: roomUsers,
    );
  }

  Future<Room> createRoom(types.User otherUser) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final query = await FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: firebaseUser!.uid)
        .get();

    final rooms = await processRoomsQuery(firebaseUser!, query);

    try {
      return rooms.firstWhere((room) {
        if (room.isGroup) return false;

        final userIds = room.users.map((u) => u.id);
        return userIds.contains(firebaseUser!.uid) &&
            userIds.contains(otherUser.id);
      });
    } catch (e) {
      // Do nothing if room does not exist
      // Create a new room instead
    }

    final currentUser = await fetchUser(firebaseUser!.uid);
    final users = [currentUser, otherUser];

    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'imageUrl': null,
      'isGroup': false,
      'name': null,
      'userIds': users.map((u) => u.id).toList(),
    });

    return Room(
      id: room.id,
      isGroup: false,
      users: users,
    );
  }

  Future<void> createUserInFirestore(types.User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set({
      'avatarUrl': user.avatarUrl,
      'firstName': user.firstName,
      'lastName': user.lastName,
    });
  }

  Stream<List<types.Message>> messages(String roomId) {
    return FirebaseFirestore.instance
        .collection('rooms/$roomId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.fold<List<types.Message>>(
          [],
          (previousValue, element) {
            final data = element.data();

            if (data != null) {
              data['id'] = element.id;
              data['timestamp'] = element['timestamp']?.seconds;
              return [...previousValue, types.Message.fromJson(data)];
            }

            return previousValue;
          },
        );
      },
    );
  }

  Stream<List<Room>> rooms() {
    if (firebaseUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: firebaseUser!.uid)
        .snapshots()
        .asyncMap((query) => processRoomsQuery(firebaseUser!, query));
  }

  void sendMessage(dynamic partialMessage, String roomId) async {
    if (firebaseUser == null) return;

    types.Message? message;

    if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        authorId: firebaseUser!.uid,
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        authorId: firebaseUser!.uid,
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        authorId: firebaseUser!.uid,
        id: '',
        partialText: partialMessage,
      );
    }

    if (message != null) {
      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'id');
      messageMap['timestamp'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('rooms/$roomId/messages')
          .add(messageMap);
    }
  }

  void updateMessage(types.Message message, String roomId) async {
    if (firebaseUser == null) return;
    if (message.authorId != firebaseUser!.uid) return;

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'id' || key == 'timestamp');

    await FirebaseFirestore.instance
        .collection('rooms/$roomId/messages')
        .doc(message.id)
        .update(messageMap);
  }

  Stream<List<types.User>> users() {
    if (firebaseUser == null) return const Stream.empty();
    return FirebaseFirestore.instance.collection('users').snapshots().map(
          (snapshot) => snapshot.docs.fold<List<types.User>>(
            [],
            (previousValue, element) {
              if (firebaseUser!.uid == element.id) return previousValue;

              return [...previousValue, processUserDocument(element)];
            },
          ),
        );
  }
}
