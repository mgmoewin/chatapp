import 'package:chatapp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // get instace of firestore & firebase auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*

  List<Map<String,dynamic>> = 

[
  {
    'email': test@gmail.com,
    'id': ..
  }, 
  {
    'email':moe@gmail.com
    'id': ..
  }
]

  */

  // get user stream
  Stream<List<Map<String, dynamic>>> getusersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();
        // return user
        return user;
      }).toList();
    });
  }

  //Get all user steam except blocked users
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          // get block user ids
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

          // get all users
          final usersSnapshot = await _firestore.collection('Users').get();

          // return a stream list, excluding current user and block users
          final usersData = await Future.wait(
            // get all doc
            usersSnapshot.docs
                .
                // expectiong current user and blocked users
                where(
                  (doc) =>
                      doc.data()['email'] != currentUser.email &&
                      !blockedUserIds.contains(doc.id),
                )
                .map((doc) async {
                  // look at each user
                  final userData = doc.data();
                  // and their chat rooms
                  final chatRoomID = [currentUser.uid, doc.id]..sort();
                  // count the number of unread messages
                  final unreadMessageSnapshot = await _firestore
                      .collection("chat_rooms")
                      .doc(chatRoomID.join("_"))
                      .collection("messages")
                      .where('receiverId', isEqualTo: currentUser.uid)
                      .where('isRead', isEqualTo: false)
                      .get();

                  userData['unreadCount'] = unreadMessageSnapshot.docs.length;

                  return userData;
                })
                .toList(),
          );

          return usersData;
        });
  }

  // send message method
  Future<void> sendMessage(String receiverId, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp tiemstamp = Timestamp.now();

    // create a new message object
    Message newMessage = Message(
      senderId: currentUserID,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: tiemstamp.toDate(),
      isRead: false,
    );

    //contruct chat room id for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    //add message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // get messages stream
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room id
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // return messages stream ordered by timestamp
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    //get chat room
    List<String> ids = [currentUserId, messageId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // get unread message
    final unreadMessagesQuery = _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .where("receiverId", isEqualTo: currentUserId)
        .where("isRead", isEqualTo: false);

    final unreadMessagesSnapshot = await unreadMessagesQuery.get();

    // go through each messages and mark as read
    for (var messageDoc in unreadMessagesSnapshot.docs) {
      await messageDoc.reference.update({"isRead": true});
    }
  }

  // Report User
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportby': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('Reports').add(report);
  }

  // block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockUsers')
        .doc(userId)
        .set({});

    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String blockUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockUsers')
        .doc(blockUserId)
        .delete();

    notifyListeners();
  }

  // get block user stream
  Stream<List<Map<String, dynamic>>> getBlockUserStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          // get list of block user ids
          final blockUserIds = snapshot.docs.map((doc) => doc.id).toList();

          final userDoc = await Future.wait(
            blockUserIds.map(
              (id) => _firestore.collection('Users').doc(id).get(),
            ),
          );

          // return a  list
          return userDoc
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
  }
}
