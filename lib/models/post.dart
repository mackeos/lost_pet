import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String postUrl;
  final String description;
  final String uid;
  final String username;
  final String profileImage;
  final String type;
  final datePosted;
  final GeoPoint location;

  const Post({
    required this.postId,
    required this.postUrl,
    required this.description,
    required this.uid,
    required this.username,
    required this.profileImage,
    required this.datePosted,
    required this.type,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "postUrl": postUrl,
        "description": description,
        "uid": uid,
        "username": username,
        "profileImage": profileImage,
        "datePosted": datePosted,
        "type": type,
        "location": location,
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
      type: jsonSnapshot["type"],
      location: jsonSnapshot["location"],
    );
  }
}
