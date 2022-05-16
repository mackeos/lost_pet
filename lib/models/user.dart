import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String profileImage;
  final String username;
  final List followers;
  final List followings;

  const User(
      {required this.username,
      required this.uid,
      required this.profileImage,
      required this.email,
      required this.followers,
      required this.followings});

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "profile_image": profileImage,
        "followers": followers,
        "followings": followings,
      };

  static User fromJson(DocumentSnapshot snap) {
    var jsonSnapshot = snap.data() as Map<String, dynamic>;
    return User(
      username: jsonSnapshot["username"],
      uid: jsonSnapshot["uid"],
      email: jsonSnapshot["email"],
      profileImage: jsonSnapshot["profile_image"],
      followers: jsonSnapshot["followers"],
      followings: jsonSnapshot["followings"],
    );
  }
}
