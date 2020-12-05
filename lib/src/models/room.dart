import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

@immutable
class Room {
  const Room({
    @required this.id,
    this.imageUrl,
    @required this.isGroup,
    this.name,
    @required this.users,
  });

  final String id;
  final String imageUrl;
  final bool isGroup;
  final String name;
  final List<types.User> users;
}
