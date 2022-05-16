import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_pet/resources/storage_methods.dart';

import 'package:lost_pet/models/user.dart' as user_model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<user_model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return user_model.User.fromJson(snapshot);
  }

  Future<String> signupUser({
    required String email,
    required String password,
    required String username,
    required Uint8List profileImage,
  }) async {
    String res = "Error signing up";
    final snapShot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (snapShot.docs.isEmpty) {
      try {
        if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty) {
          UserCredential userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          print('User created: ${userCred.user!.email}');

          String imageUrl = await StorageMethods()
              .uploadImageToStorage('profile_images', profileImage, false);

          user_model.User user = user_model.User(
            email: email,
            uid: userCred.user!.uid,
            profileImage: imageUrl,
            username: username,
            followers: [],
            followings: [],
          );

          await _firestore.collection('users').doc(userCred.user!.uid).set(
                user.toJson(),
              );
          res = 'Success';
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          res = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          res = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          res = 'The email address is badly formatted.';
        } else {}
      }
    } else {
      res = 'Username already exists';
    }
    print(res);
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Error logging in";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'Success';
      } else {
        res = 'Please enter an email and password.';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}

bool getUsername(String username) {
  bool result = false;
  FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get()
      .then(
        (res) => result = true,
        onError: (e) => print("Error completing: $e"),
      );
  return result;
}
