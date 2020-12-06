import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/src/models/room.dart';

import '../flutter_firebase_chat_core.dart';

class CreateChatData {
  const CreateChatData({
    @required this.otherUser,
  });

  final types.User otherUser;
}

class CreateGroupData {
  const CreateGroupData({
    this.imageUrl,
    @required this.name,
    @required this.users,
  });

  final String imageUrl;
  final String name;
  final List<types.User> users;
}

Future<Room> createRoom(auth.User firebaseUser, dynamic roomData) async {
  if (roomData is CreateChatData) {
    final query = await FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: firebaseUser.uid)
        .get();

    final rooms = await processRoomsQuery(firebaseUser, query);

    final existingRoom = rooms.firstWhere((room) {
      if (room.isGroup) return false;

      final userIds = room.users.map((u) => u.id);
      return (userIds.contains(firebaseUser.uid) &&
          userIds.contains(roomData.otherUser.id));
    });

    if (existingRoom != null) {
      return existingRoom;
    }
  }

  final currentUser = await fetchUser(firebaseUser.uid);

  final imageUrl = (roomData is CreateChatData) ? null : roomData.imageUrl;
  final isGroup = (roomData is CreateGroupData);
  final name = (roomData is CreateChatData) ? null : roomData.name;
  final users = (roomData is CreateChatData)
      ? [currentUser, roomData.otherUser]
      : [currentUser] + roomData.users.map((u) => u);

  final room = await FirebaseFirestore.instance.collection('rooms').add({
    'imageUrl': imageUrl,
    'isGroup': isGroup,
    'userIds': users.map((u) => u.id),
    'name': name,
  });

  return new Room(
    id: room.id,
    isGroup: isGroup,
    users: users,
    name: name,
    imageUrl: imageUrl,
  );
}

void createUserInFirestore(types.User user) async {
  await FirebaseFirestore.instance.collection('users').doc(user.id).set({
    'avatarUrl': user.avatarUrl,
    'firstName': user.firstName,
    'lastName': user.lastName,
  });
}

Future<types.User> fetchUser(String userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return processUserDocument(doc);
}

Future<List<Room>> processRoomsQuery(
    auth.User firebaseUser, QuerySnapshot query) async {
  final futures = query.docs.map((doc) async {
    String imageUrl = doc.get('imageUrl');
    final bool isGroup = doc.get('isGroup');
    String name = doc.get('name');
    final List<dynamic> userIds = doc.get('userIds');

    final users = await Future.wait(userIds.map((userId) => fetchUser(userId)));

    if (!isGroup) {
      final otherUser = users.firstWhere((u) => u.id != firebaseUser.uid);

      if (otherUser != null) {
        imageUrl = otherUser.avatarUrl;
        name = '${otherUser.firstName} ${otherUser.lastName}';
      }
    }

    final room = Room(
      id: doc.id,
      imageUrl: imageUrl,
      isGroup: isGroup,
      name: name,
      users: users,
    );

    return room;
  });

  return await Future.wait(futures);
}

types.User processUserDocument(DocumentSnapshot doc) {
  final String avatarUrl = doc.get('avatarUrl');
  final String firstName = doc.get('firstName');
  final String lastName = doc.get('lastName');

  final user = types.User(
    avatarUrl: avatarUrl,
    firstName: firstName,
    id: doc.id,
    lastName: lastName,
  );

  return user;
}
