import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lost_pet/resources/firestore_methods.dart';
import 'package:lost_pet/screens/comments_screen.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLength = 0;
  bool _isExpanded = false;
  bool _showPreview = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap["postId"])
          .collection("comments")
          .get()
          .then((value) {
        setState(() {
          commentLength = value.docs.length;
        });
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  static Future<void> openMap(String latitude, String longitude) async {
    final Uri _googleMapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (!await launchUrl(_googleMapUrl))
      throw 'Could not launch $_googleMapUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: mobileBackgroundColor,
        border: Border.all(
          color: Colors.blue,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 15,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(widget.snap['profileImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      widget.snap['username'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FirebaseAuth.instance.currentUser!.uid == widget.snap["uid"]
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                shrinkWrap: true,
                                children: [
                                  "Delete",
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () async {
                                          FirestoreMethods().deletePost(
                                              widget.snap["postId"]);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Text(e),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.more_vert),
                      )
                    : Container(),
              ],
            ),
          ),
          GestureDetector(
            onLongPress: () {
              setState(() {
                _showPreview = true;
              });
            },
            onLongPressEnd: (details) {
              setState(() {
                _showPreview = false;
              });
            },
            child: SizedBox(
              height: _showPreview
                  ? null
                  : MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              child: Image(
                image: NetworkImage(
                  widget.snap['postUrl'],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    openMap(widget.snap["location"].latitude.toString(),
                        widget.snap["location"].longitude.toString());
                  },
                  icon: Icon(Icons.map)),
              IconButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            snap: widget.snap,
                          ),
                        ),
                      ),
                  icon: Icon(Icons.comment)),
              IconButton(onPressed: () {}, icon: Icon(Icons.send)),
              Expanded(
                child: Container(),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  DateFormat.yMMMMd().format(
                    widget.snap["datePosted"].toDate(),
                  ),
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 5),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: primaryColor,
                      ),
                      children: [
                        TextSpan(
                          text: widget.snap['username'] + " ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: widget.snap['description'] ??
                              "No description provided",
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        snap: widget.snap,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "View all $commentLength comments",
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
