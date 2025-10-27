const functions = require['firebase-functions'];
const admin = require['firebase-admin'];
admin.initializeApp();

exports.sendNotificationOnMessage = functions.firestore
.document('chat_rooms/{chatRoomId}/messages/{messageId}')
.onCreate( async(snapshot, context) => {
    const message = snapshot.data();
    
    try {
        const receiversDoc = await admin.firestore().collection('Users').doc(message.receiverId).get();

        if(!receiversDoc.exists) {
            console.log('Receiver not found');
            return null;
        }

        const receiverData = receiversDoc.data();
        const token = receiversData.token;

        if(!token) {
            console.log('Token not found');
            return null;
        }

        const messagePayload = {
            token: token,
            notification: {
                title: 'New Message',
                body: message.text,
                
            },
            android: {
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
            },
            apns: {
                payload: {
                    aps: {
                        category: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                },
            },
        };

        
        // send the notification
        const response = await admin.messaging().send(messagePayload);
        console.log('Notification sent successfully', response);
        return response;
    } catch (error) {
        console.log('Error sending notification', error);
        if(error.code && error.message) {
            console.log('Error code', error.code);
            console.log('Error message', error.message);
        }throw new Error('Error sending notification');



        }
    }
);



    