import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// Fetches user from Firebase and returns a promise
Future<types.User> fetchUser(String userId, {types.Role? role}) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return processUserDocument(doc, role: role);
}

/// Returns a list of [types.Room] created from Firebase query.
/// If room has 2 participants, sets correct room name and image.
Future<List<types.Room>> processRoomsQuery(
  User firebaseUser,
  QuerySnapshot<Map<String, dynamic>> query,
) async {
  final futures = query.docs.map(
    (doc) => processRoomDocument(doc, firebaseUser),
  );

  return await Future.wait(futures);
}

/// Returns a [types.Room] created from Firebase document
Future<types.Room> processRoomDocument(
  DocumentSnapshot<Map<String, dynamic>> doc,
  User firebaseUser,
) async {
  final createdAt = doc.data()?['createdAt'] as Timestamp?;
  var imageUrl = doc.data()?['imageUrl'] as String?;
  final metadata = doc.data()?['metadata'] as Map<String, dynamic>?;
  var name = doc.data()?['name'] as String?;
  final type = doc.data()!['type'] as String;
  final updatedAt = doc.data()?['updatedAt'] as Timestamp?;
  final userIds = doc.data()!['userIds'] as List<dynamic>;
  final userRoles = doc.data()?['userRoles'] as Map<String, dynamic>?;

  final users = await Future.wait(
    userIds.map(
      (userId) => fetchUser(
        userId as String,
        role: types.getRoleFromString(userRoles?[userId] as String?),
      ),
    ),
  );

  if (type == types.RoomType.direct.toShortString()) {
    try {
      final otherUser = users.firstWhere(
        (u) => u.id != firebaseUser.uid,
      );

      imageUrl = otherUser.imageUrl;
      name = '${otherUser.firstName} ${otherUser.lastName}';
    } catch (e) {
      // Do nothing if other user is not found, because he should be found.
      // Consider falling back to some default values.
    }
  }

  final room = types.Room(
    createdAt: createdAt?.millisecondsSinceEpoch,
    id: doc.id,
    imageUrl: imageUrl,
    metadata: metadata,
    name: name,
    type: types.getRoomTypeFromString(type),
    updatedAt: updatedAt?.millisecondsSinceEpoch,
    users: users,
  );

  return room;
}

/// Returns a [types.User] created from Firebase document
types.User processUserDocument(
  DocumentSnapshot<Map<String, dynamic>> doc, {
  types.Role? role,
}) {
  final createdAt = doc.data()?['createdAt'] as Timestamp?;
  final firstName = doc.data()?['firstName'] as String?;
  final imageUrl = doc.data()?['imageUrl'] as String?;
  final lastName = doc.data()?['lastName'] as String?;
  final lastSeen = doc.data()?['lastSeen'] as Timestamp?;
  final metadata = doc.data()?['metadata'] as Map<String, dynamic>?;
  final roleString = doc.data()?['role'] as String?;
  final updatedAt = doc.data()?['updatedAt'] as Timestamp?;

  final user = types.User(
    createdAt: createdAt?.millisecondsSinceEpoch,
    firstName: firstName,
    id: doc.id,
    imageUrl: imageUrl,
    lastName: lastName,
    lastSeen: lastSeen?.millisecondsSinceEpoch,
    metadata: metadata,
    role: role ?? types.getRoleFromString(roleString),
    updatedAt: updatedAt?.millisecondsSinceEpoch,
  );

  return user;
}
