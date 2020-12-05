import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/src/models/room.dart';
import 'package:flutter_firebase_chat_core/src/util.dart';

class FirebaseChatCore {
  User firebaseUser = FirebaseAuth.instance.currentUser;

  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      firebaseUser = user;
    });
  }

  static final FirebaseChatCore instance =
      FirebaseChatCore._privateConstructor();

  Stream<List<types.Message>> messages(String roomId) {
    return FirebaseFirestore.instance
        .collection('rooms/$roomId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) {
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        data['timestamp'] = data['timestamp'].seconds;
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
}
