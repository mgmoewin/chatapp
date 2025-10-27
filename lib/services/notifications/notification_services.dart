import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _messageController = BehaviorSubject<RemoteMessage>();
  // request permission :
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // setup interaction
  void setupInterraction() {
    FirebaseMessaging.onMessage.listen((event) {
      print('got a message whilst in the foreground');
      print("Messaege data: ${event.data}");
      _messageController.sink.add(event);
    });

    // user open message
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('Message clicked!');
      print("Messaege data: ${event.data}");
    });
  }

  void dispose() {
    _messageController.close();
  }

  // setup token listener

  // each device has a token ,we will get this token so that we know which device to sent a notification to
  void setupTokenListener() {
    FirebaseMessaging.instance.getToken().then((token) {
      saveTokenToDatabase(token);
    });
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  // save device token
  void saveTokenToDatabase(String? token) {
    // get current user id
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // if the current user is logged in & it has device token, save it to db
    if (userId != null && token != null) {
      FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }
}

// clear device token

//it's important to clear the device token in the case that the user loggs out

Future<void> clearTokenOnLogout(String userId) async {
  try {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'fcmToken': FieldValue.delete(),
    });
    print("Token cleared successfully");
  } catch (e) {
    print("Failed to clear token : $e");
  }
}
