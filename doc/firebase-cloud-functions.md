---
id: firebase-cloud-functions
title: Cloud Functions
---

This is an example of a cloud function that sets a message's status to `delivered` once the message is received on Firebase.

```js
const functions = require('firebase-functions')

exports.changeMessageStatus = functions.firestore
  .document('rooms/{roomId}/messages/{messageId}')
  .onWrite((change) => {
    const message = change.after.data()
    if (message) {
      if (['delivered', 'seen', 'sent'].includes(message.status)) {
        return null
      } else {
        return change.after.ref.update({
          status: 'delivered',
        })
      }
    } else {
      return null
    }
  })
```

This is an example of a cloud function that sets room's `lastMessages` to the most recent message sent once recieved in Firestore.

```js
const admin = require('firebase-admin')
const functions = require('firebase-functions')

admin.initializeApp()

const db = admin.firestore()

exports.changeLastMessage = functions.firestore
  .document('rooms/{roomId}/messages/{messageId}')
  .onWrite((change, context) => {
    const message = change.after.data()
    if (message) {
      return db.doc('rooms/' + context.params.roomId).update({
        lastMessages: [message],
      })
    } else {
      return null
    }
  })
```

:::important

Starting from March 15, 2021, you will need a paid plan to use Cloud Functions, so there might be a better way to do it. We might explore options to create more examples, including `seen` status and push notifications.

:::
