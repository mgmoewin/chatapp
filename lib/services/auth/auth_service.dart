import 'package:chatapp/services/notifications/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instace of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign in method
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info if it does not exist in firestore
      _firestore.collection("Users").doc(userCredential.user?.uid).set({
        'email': email,
        'uid': userCredential.user?.uid,
      });

      // return user credential
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // // sign up method
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // create user document in firestore
      _firestore.collection("Users").doc(userCredential.user?.uid).set({
        'email': email,
        'uid': userCredential.user?.uid,
      });

      // return user credential
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out method
  Future<void> signOut() async {
    // get the current user ID before signing out
    final String? userId = _auth.currentUser?.uid;

    // sign out from firebase
    await _auth.signOut();

    // clear the notification token if a user was logged in
    if (userId != null) {
      await clearTokenOnLogout(userId);
    }
  }

  // delete account
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // delete the user's data from firestore
      await _firestore.collection("Users").doc(user.uid).delete();

      // delete the user's auth record
      await user.delete();
    }
  }

  // error handling method
}
