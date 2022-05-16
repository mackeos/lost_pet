import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String postUrl;
  final String description;
  final String uid;
  final String username;
  final String profileImage;
  final datePosted;

  const Post({
    required this.postId,
    required this.postUrl,
    required this.description,
    required this.uid,
    required this.username,
    required this.profileImage,
    required this.datePosted,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "postUrl": postUrl,
        "description": description,
        "uid": uid,
        "username": username,
        "profileImage": profileImage,
        "datePosted": datePosted,
      };

  static Post fromJson(DocumentSnapshot snap) {
    var jsonSnapshot = snap.data() as Map<String, dynamic>;
    return Post(
      username: jsonSnapshot["username"],
      uid: jsonSnapshot["uid"],
      postUrl: jsonSnapshot["postUrl"],
      profileImage: jsonSnapshot["profileImage"],
      postId: jsonSnapshot["postId"],
      datePosted: jsonSnapshot["datePosted"],
      description: jsonSnapshot["description"],
    );
  }
}
