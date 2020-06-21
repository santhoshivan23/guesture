const functions = require('firebase-functions');
const admin = require('firebase-admin')

admin.initializeApp(functions.config().firebase);

var notifData;
var uid;

exports.notifTrigger = functions.firestore.document('users/{uid}/notifications/{notifID}').onWrite((snapshot, context) => {
    notifData = snapshot.after.data();
    uid = snapshot.after.ref.parent.parent.id;
    admin.firestore().collection('users/' + uid + '/tokens').get().then((snapshots) => {
        var tokens = [];
        if (snapshots.empty) {
            console.log('No tokens!');
            return;
        }
        else {
            for (var tokenDoc of snapshots.docs) {
                tokens.push(tokenDoc.data().token)
            }

            var payload = {
                "notification": {
                    "title": notifData.title,
                    "body": notifData.content,
                    "sound": "default",
                    "clickAction": "FLUTTER_NOTIFICATION_CLICK"
                },
                

            }
            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                console.log("Success");
                return;
            }).catch((err) => {
                console.log(err);
            })
        }
    }).catch((err) => {
        console.log(err);
    })

})