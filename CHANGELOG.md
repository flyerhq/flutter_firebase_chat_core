## 1.1.0

This release marks a major chat architecture overhaul based on a community feedback. In the future we don't expect such big changes in one release and will try to do backwards compatible code as much as possible.

- **BREAKING CHANGE**: [FileMessage] `fileName` is renamed to `name`
- **BREAKING CHANGE**: [ImageMessage] `imageName` is renamed to `name`
- **BREAKING CHANGE**: [Messages] `timestamp` is renamed to `createdAt`
- **BREAKING CHANGE**: [Status] `read` is renamed to `seen`
- **BREAKING CHANGE**: [User] `avatarUrl` is renamed to `imageUrl`
- New `custom` and `unsupported` message types. First one is used to build any message you want, second one is to support backwards compatibility

## 1.0.4

- Update dependencies

## 1.0.3

- **BREAKING CHANGE**: Updated `cloud_firestore` to version 2
- Update to Flutter 2.2

## 1.0.2

- Fix static analysis warning

## 1.0.1

- Add metadata to the room class for easier extensibility. Thanks @alihen for the PR!

## 1.0.0

- Public release

## 0.3.0

- Add docs

## 0.2.0

- Update types

## 0.1.2

- Add documentation comments

## 0.1.1

- Fix static analysis warning

## 0.1.0

- Update to Flutter 2

## 0.0.8

- Update to the latest chat UI

## 0.0.7

- Handle attachments upload

## 0.0.6

- Update message when preview data fetched

## 0.0.5

- Update LICENSE

## 0.0.4

- Finish core

## 0.0.3

- Added chat UI

## 0.0.2

- Added example

## 0.0.1

- Initial release
