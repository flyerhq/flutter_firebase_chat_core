---
id: firebase-cloud-functions
title: Cloud Functions
---

This is an example of a cloud function that sets a message's status to delivered once the message is received on Firebase.

```ts
import * as functions from 'firebase-functions'

export const changeMessageStatus = functions.firestore
  .document('rooms/{roomId}/messages/{messageId}')
  .onWrite((change) => {
    const message = change.after.data()
    if (message) {
      if (['delivered', 'read'].includes(message.status)) {
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

:::important

This function was created using a deprecated Node 8 environment on a free Firebase plan. Starting from March 15, 2021, you will need a paid plan to use Cloud Functions, so there might be a better way to do it. We will explore options to create more examples, including `read` status and push notifications.

:::
