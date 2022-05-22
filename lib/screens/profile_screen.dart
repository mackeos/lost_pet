import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lost_pet/resources/auth_methods.dart';
import 'package:lost_pet/screens/login_screen.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';
import 'package:lost_pet/widgets/Follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLength = 0;
  int followersLength = 0;
  int followingsLength = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      //Get post length
      var postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      setState(() {
        userData = userSnapshot.data()!;
        postLength = postSnapshot.docs.length;
        followersLength = userData['followers'].length;
        followingsLength = userData['followings'].length;
        isFollowing = userData['followers']
            .contains(FirebaseAuth.instance.currentUser!.uid);
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Container(
              color: mobileBackgroundColor,
              child: const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: barColor,
              title: Text(userData['username']),
              actions: <Widget>[
                FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () async {
                          await AuthMethods().signOutUser();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.message),
                        onPressed: () {},
                      ),
              ],
            ),
            body: Center(
              child: Container(
                width: webScreenSize.toDouble(),
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(userData['profileImage']),
                                radius: 50,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        BuildStatsColumn(postLength, "posts"),
                                        BuildStatsColumn(
                                            followersLength, "followers"),
                                        BuildStatsColumn(
                                            followingsLength, "followings"),
                                      ],
                                    ),
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            buttonColor: mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: 'Edit Profile',
                                            textColor: primaryColor,
                                            onPressed: () {},
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                buttonColor: Colors.white,
                                                borderColor: Colors.grey,
                                                text: 'Unfollow',
                                                textColor: Colors.black,
                                                onPressed: () {},
                                              )
                                            : FollowButton(
                                                buttonColor: Colors.blue,
                                                borderColor: Colors.blue,
                                                text: 'Follow',
                                                textColor: Colors.white,
                                                onPressed: () {},
                                              ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: secondaryColor,
                    ),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: widget.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              DocumentSnapshot post =
                                  (snapshot.data! as dynamic).docs[index];
                              return Container(
                                child: Image(
                                  image: NetworkImage(post['postUrl']),
                                  fit: BoxFit.cover,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text('No posts'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Column BuildStatsColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$num',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
