import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// Fetches user from Firebase and returns a promise
Future<types.User> fetchUser(String userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return processUserDocument(doc);
}

/// Returns a list of [types.Room] created from Firebase query.
/// If room has 2 participants, sets correct room name and image.
Future<List<types.Room>> processRoomsQuery(
  User firebaseUser,
  QuerySnapshot query,
) async {
  final futures = query.docs.map((doc) async {
    String? imageUrl;
    Map<String, dynamic>? metadata;
    String? name;

    try {
      imageUrl = doc.get('imageUrl') as String?;
      metadata = doc.get('metadata') as Map<String, dynamic>?;
      name = doc.get('name') as String?;
    } catch (e) {
      // Ignore errors since all those fields are optional
    }

    final type = doc.get('type') as String;
    final userIds = doc.get('userIds') as List<dynamic>;

    final users = await Future.wait(
      userIds.map(
        (userId) => fetchUser(userId as String),
      ),
    );

    if (type == 'direct') {
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

    final room = types.Room(
      id: doc.id,
      imageUrl: imageUrl,
      metadata: metadata,
      name: name,
      type: type == 'direct' ? types.RoomType.direct : types.RoomType.group,
      users: users,
    );

    return room;
  });

  return await Future.wait(futures);
}

/// Returns a [types.User] created from Firebase document
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
