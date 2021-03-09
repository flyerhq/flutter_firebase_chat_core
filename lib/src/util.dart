import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import './models/room.dart';

Future<types.User> fetchUser(String userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return processUserDocument(doc);
}

Future<List<Room>> processRoomsQuery(
  User firebaseUser,
  QuerySnapshot query,
) async {
  final futures = query.docs.map((doc) async {
    var imageUrl = doc.get('imageUrl') as String?;
    final isGroup = doc.get('isGroup') as bool;
    var name = doc.get('name') as String?;
    final userIds = doc.get('userIds') as List<dynamic>;

    final users = await Future.wait(
      userIds.map(
        (userId) => fetchUser(userId as String),
      ),
    );

    if (!isGroup) {
      try {
        final otherUser = users.firstWhere(
          (u) => u.id != firebaseUser.uid,
        );

        imageUrl = otherUser.avatarUrl;
        name = '${otherUser.firstName} ${otherUser.lastName}';
      } catch (e) {
        // Do nothing if other user is not found, because he should be found.
        // Consider falling back to some default values.
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
  final avatarUrl = doc.get('avatarUrl') as String?;
  final firstName = doc.get('firstName') as String?;
  final lastName = doc.get('lastName') as String?;

  final user = types.User(
    avatarUrl: avatarUrl,
    firstName: firstName,
    id: doc.id,
    lastName: lastName,
  );

  return user;
}
