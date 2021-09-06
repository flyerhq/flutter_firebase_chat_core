import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Class that represents config for setting custom names for rooms and users
/// collections. Call
/// FirebaseChatCore.instance.setConfig(
/// const FirebaseChatCoreConfig(
///    'roomsCollectionName', 'usersCollectionName'),
/// );
/// before doing anything else with [FirebaseChatCore.instance]
/// When using custom names don't forget to update your security rules

@immutable
class FirebaseChatCoreConfig {
  const FirebaseChatCoreConfig(
      this.roomsCollectionName, this.usersCollectionName);

  /// Parameter to set rooms collection name
  final String roomsCollectionName;

  /// Parameter to set users collection name
  final String usersCollectionName;
}
