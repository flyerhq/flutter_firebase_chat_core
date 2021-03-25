---
id: firebase-rules
title: Security Rules
---

This is a drop-in example of [Firebase Security Rules](https://firebase.google.com/docs/rules) designed for a typical chat application. You can copy and paste it in your project's Firebase console, Firestore service, Rules tab.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Function available for all collections
    // Checks that request is coming from an authenticated user
    function isSignedIn() {
      return request.auth != null;
    }

    // Rules for the users collection
    match /users/{userId} {
      // Validates user's object format
      // Remove this if you don't plan to provide first or last names
      function isUserCorrect() {
        return isSignedIn() && request.resource.data.firstName is string && request.resource.data.lastName is string;
      }

      // Checks that the document was created by currently logged in user
      function isSelf() {
        return request.auth.uid == userId;
      }

      // Rules set for the users collection
      allow create: if isUserCorrect();
      allow delete: if isSelf();
      allow read: if isSignedIn();
      allow update: if isUserCorrect() && isSelf();
    }

    // Rules for the rooms collection
    match /rooms/{roomId} {
      // Checks that currently logged in user exists in users collection
      function userExists() {
        return isSignedIn() && exists(/databases/$(database)/documents/users/$(request.auth.uid));
      }

      // Checks that currently logged in user is in the room
      function isUserInRoom() {
        return isSignedIn() && request.auth.uid in resource.data.userIds;
      }

      // Validates room's object format
      function isRoomCorrect() {
        return request.resource.data.type is string && request.resource.data.userIds is list;
      }

      // Rules set for the rooms collection
      allow create: if userExists() && isRoomCorrect();
      allow delete, read, update: if isUserInRoom();

      // Rules for the messages collection
      match /messages/{messageId} {
        // Checks that currently logged in user is in the room
        function isUserInRoomUsingGet() {
          return isSignedIn() && request.auth.uid in get(/databases/$(database)/documents/rooms/$(roomId)).data.userIds;
        }

        // Validates message's object format
        function isMessageCorrect() {
      	  return request.resource.data.authorId is string && request.resource.data.timestamp is timestamp;
        }

        // Checks that message's author is currently logged in user
        function isMyMessage() {
          return request.auth.uid == resource.data.authorId;
        }

        // Rules set for the messages collection
        allow create: if isSignedIn() && isMessageCorrect();
        allow delete, read: if isUserInRoomUsingGet();
        allow update: if isUserInRoomUsingGet() && isMyMessage();
      }
    }
  }
}
```

To learn more head over to the [Firebase Security Rules](https://firebase.google.com/docs/rules) website.
