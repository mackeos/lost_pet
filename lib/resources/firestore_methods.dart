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
}
