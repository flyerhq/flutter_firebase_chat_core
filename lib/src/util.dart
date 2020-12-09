import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/src/models/room.dart';

Future<types.User> fetchUser(String userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return processUserDocument(doc);
}

Future<List<Room>> processRoomsQuery(
    User firebaseUser, QuerySnapshot query) async {
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
