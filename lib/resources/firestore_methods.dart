import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_pet/models/post.dart';
import 'package:lost_pet/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List image,
    String uid,
    String username,
    String profileImage,
    String type,
    GeoPoint location,
  ) async {
    String res = "Something went wrong";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', image, true);

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        postUrl: photoUrl,
        datePosted: DateTime.now(),
        profileImage: profileImage,
        type: type,
        location: location,
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "Success";
    } catch (e) {
      print(e);
      res = e.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String comment, String uid,
      String username, String profileImage) async {
    String res = "Something went wrong";

    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'commentId': commentId,
          'comment': comment,
          'uid': uid,
          'username': username,
          'profileImage': profileImage,
          'dateCom': DateTime.now(),
          'postId': postId,
        });
      } else {
        res = "Comment cannot be empty";
      }
    } catch (e) {
      print(e);
      res = e.toString();
    }

    return res;
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['followings'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'followings': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'followings': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> editProfile({
    required String uid,
    required String username,
    required String profileImage,
  }) async {
    String res = "Something went wrong";

    try {
      /* String imageUrl = await StorageMethods()
          .uploadImageToStorage('profile_images', profileImage, false); */
      _firestore.collection('users').doc(uid).update(
        {
          'username': username,
          'profileImage': profileImage,
        },
      );

      CollectionReference<Map<String, dynamic>> posts =
          _firestore.collection('posts');

      var response = await posts.where('uid', isEqualTo: uid).get();

      var batch = FirebaseFirestore.instance.batch();
      response.docs.forEach((doc) {
        var docRef = posts.doc(doc.id);
        batch.update(
            docRef, {'username': username, 'profileImage': profileImage});
      });

      batch.commit().then((a) {
        print(
            'updated all usersnames and profile pics inside posts collection');
      });

      res = "Success";
    } catch (e) {
      print(e);
      res = e.toString();
    }

    return res;
  }

  Future<String> getUsername(String uid) async {
    String username = "";
    await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((value) => username = value.data()!['username']);

    return username;
  }
}
