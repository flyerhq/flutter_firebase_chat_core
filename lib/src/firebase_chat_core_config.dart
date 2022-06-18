import 'package:meta/meta.dart';

/// Class that represents the chat config. Can be used for setting custom names
/// for rooms and users collections. Call [FirebaseChatCore.instance.setConfig]
/// before doing anything else with [FirebaseChatCore.instance] if you want to
/// change the default collection names. When using custom names don't forget
/// to update your security rules and indexes.
@immutable
class FirebaseChatCoreConfig {
  const FirebaseChatCoreConfig(
    this.firebaseAppName,
    this.roomsCollectionName,
    this.usersCollectionName,
  );

  /// Property to set custom firebase app name.
  final String? firebaseAppName;

  /// Property to set rooms collection name.
  final String roomsCollectionName;

  /// Property to set users collection name.
  final String usersCollectionName;
}
