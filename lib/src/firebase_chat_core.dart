import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/src/models/room.dart';
import 'package:flutter_firebase_chat_core/src/util.dart';
import 'package:meta/meta.dart';

class FirebaseChatCore {
  User firebaseUser = FirebaseAuth.instance.currentUser;

  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      firebaseUser = user;
    });
  }

  static final FirebaseChatCore instance =
      FirebaseChatCore._privateConstructor();

  Future<Room> createGroupRoom({
    String imageUrl,
    @required String name,
    @required List<types.User> users,
  }) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final currentUser = await fetchUser(firebaseUser.uid);
    final roomUsers = [currentUser] + users;

    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'imageUrl': imageUrl,
      'isGroup': true,
      'name': name,
      'userIds': roomUsers.map((u) => u.id).toList(),
    });

    return Room(
      id: room.id,
      isGroup: true,
      users: roomUsers,
      imageUrl: imageUrl,
      name: name,
    );
  }

  Future<Room> createRoom(types.User otherUser) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final query = await FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: firebaseUser.uid)
        .get();

    final rooms = await processRoomsQuery(firebaseUser, query);

    final existingRoom = rooms.firstWhere((room) {
      if (room.isGroup) return false;

      final userIds = room.users.map((u) => u.id);
      return (userIds.contains(firebaseUser.uid) &&
          userIds.contains(otherUser.id));
    }, orElse: () => null);

    if (existingRoom != null) {
      return existingRoom;
    }

    final currentUser = await fetchUser(firebaseUser.uid);
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
        .map((query) {
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        data['timestamp'] = data['timestamp']?.seconds;
        return types.Message.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Room>> rooms() {
    return FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: firebaseUser.uid)
        .snapshots()
        .asyncMap((query) => processRoomsQuery(firebaseUser, query));
  }

  void sendMessage(types.Message message, String roomId) async {
    if (firebaseUser == null) return;

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'id');
    messageMap['timestamp'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('rooms/$roomId/messages')
        .add(messageMap);
  }

  Stream<List<types.User>> users() {
    if (firebaseUser == null) {
      return Stream<List<types.User>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((query) {
      List<types.User> newUsers = [];
      query.docs.forEach((doc) {
        if (firebaseUser.uid == doc.id) return;
        newUsers.add(processUserDocument(doc));
      });
      return newUsers;
    });
  }
}
