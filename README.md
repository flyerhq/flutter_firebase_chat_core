# Flutter Firebase Chat Core

Actively maintained, community-driven Firebase BaaS for chat applications with an optional [chat UI](https://github.com/flyerhq/flutter_chat_ui).

<img></img>

Flyer Chat is a platform for creating in-app chat experiences using Flutter or [React Native](https://github.com/flyerhq/react-native-firebase-chat-core). This repository contains Firebase BaaS implementation for Flutter. We are also working on our more advanced SaaS and self-hosted solutions.

* **Free, open-source and community-driven**. We offer no paid plugins and strive to create an easy-to-use, almost drop-in chat experience for any application. Contributions are more than welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

* **Chat UI agnostic**. You can choose the chat UI you prefer. But if you don't have one, we provide our own free and open-source [Flutter Chat UI](https://github.com/flyerhq/flutter_chat_ui), which can be used to create a working chat in minutes.

* **Easy to use**. Returns streams of data for messages, rooms and users. [Firebase Security Rules](https://firebase.google.com/docs/rules) control access to the data. Check our [documentation](https://flyer.chat) for the info.

## Getting Started

### Requirements

`Dart >=2.12.0` and `Flutter >=2.0.0`, [Firebase](https://firebase.google.com) project.

Read our [documentation](https://flyer.chat) or see the [example](https://github.com/flyerhq/flutter_firebase_chat_core/tree/main/example) project. To run the example project you need to have your own [Firebase](https://firebase.google.com) project and depending on the platform you want to:

1. Create an iOS app with a bundle ID `chat.flyer` (*only required for the example project, you can use anything for your app*) in [Firebase console](https://console.firebase.google.com) of your project and download generated `GoogleService-Info.plist`. Put it in the `example/ios` folder. You don't need to open Xcode to do it, it will expect this file in this folder.
2. Create an Android app with package name `chat.flyer` (*only required for the example project, you can use anything for your app*) in [Firebase console](https://console.firebase.google.com) of your project and download generated `google-services.json`. Put it in the `example/android/app` folder.
3. Create a web app in [Firebase console](https://console.firebase.google.com) of your project. You will see a script that will look like this

```html
 <!-- Firebase Configuration -->
<script>
  var firebaseConfig = {
    apiKey: "...",
    authDomain: "[YOUR_PROJECT].firebaseapp.com",
    databaseURL: "https://[YOUR_PROJECT].firebaseio.com",
    projectId: "[YOUR_PROJECT]",
    storageBucket: "[YOUR_PROJECT].appspot.com",
    messagingSenderId: "...",
    appId: "1:...:web:...",
    measurementId: "G-...",
  };

  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
```
Create a `firebase-config.js` file in the `example/web` folder and put there only js part like this

```js
var firebaseConfig = {
  apiKey: "...",
  authDomain: "[YOUR_PROJECT].firebaseapp.com",
  databaseURL: "https://[YOUR_PROJECT].firebaseio.com",
  projectId: "[YOUR_PROJECT]",
  storageBucket: "[YOUR_PROJECT].appspot.com",
  messagingSenderId: "...",
  appId: "1:...:web:...",
  measurementId: "G-...",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
```

After all of this is done you will need to register a couple of users and the example app will automatically suggest email and password on the register screen, default password is `Qawsed1-`. To set up [Firebase Security Rules](https://firebase.google.com/docs/rules) so users can see only the data they should see, continue with our [documentation](https://flyer.chat).

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a pull request to the project.

## Code of Conduct

Flyer Chat has adopted the [Contributor Covenant](https://www.contributor-covenant.org) as its Code of Conduct, and we expect project participants to adhere to it. Please read [the full text](CODE_OF_CONDUCT.md) so that you can understand what actions will and will not be tolerated.

## License

Licensed under the [Apache License, Version 2.0](LICENSE)
