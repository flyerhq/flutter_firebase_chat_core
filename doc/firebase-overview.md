---
id: firebase-overview
title: Overview
---

Flyer Chat is a platform for creating in-app chat experiences using Flutter or React Native. This is the documentation for Firebase BaaS implementation for Flutter.

## How it works?

We use [Cloud Firestore](https://firebase.google.com/docs/firestore) as the backend. There we have two top-level collections, `rooms` and `users`. Let's break them down:

* `rooms` collection contains all conversations in your app. [Firebase Security Rules](https://firebase.google.com/docs/rules) are responsible for showing only those rooms where the user's in. The room contains some metadata, a participants list and a subcollection called `messages` that, in turn, contains all messages in this room.
* `users` collection contains users data, such as avatars and names. You can use this collection to render a list of users available for chat.

Both array of participant IDs in the room and documents in `users` collection use `User UID` from [Firebase Authentication](https://firebase.google.com/docs/auth) as an ID, for easier navigation through the data. That means every user of the chat should be registered using Firebase's authentication module, but if your app doesn't use Firebase as an authentication provider, you still can register in Firebase by providing your `JWT` token, so you can have your backend working together with a chat on Firebase.

[Cloud Functions](https://firebase.google.com/docs/functions) can be used for setting message's statuses and for triggering push notifications. In this documentation, you will see an [example](firebase-cloud-functions) of setting `delivered` message status, keep in mind though that you will need to switch to a paid plan to use Cloud Functions.

[Cloud Storage](https://firebase.google.com/docs/storage) can be used as a storage provider for images and files.

## Motivation

Ever estimated a simple chat for weeks of work? Didn't want to start because it is always the same boring work for an extended period of time? Was it moved to post MVP because of lack of time and resources? Were you left with a frustrated client, who couldn't understand why the thing that exists in almost every app takes that much time to implement?

We are trying to solve all this by working on a Flyer Chat.

You will say that there are libraries out there that will help create chats, but we are working on a more complete solution - very similar on completely different platforms like React Native and Flutter (we don't always work in just one) with an optional Firebase BaaS, since chat is not only UI. We are making this free and open-source so together we can create a product that works for everyone.
