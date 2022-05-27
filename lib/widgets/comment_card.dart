import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lost_pet/resources/firestore_methods.dart';
import 'package:lost_pet/utilities/colors.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  var userData = {};
  bool _isLoading = false;

  getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap["uid"])
          .get();

      setState(() {
        userData = userSnapshot.data()!;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: const CircularProgressIndicator(),
          )
        : Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 15,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    userData['profileImage'],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: userData['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.snap['comment'],
                                    style: const TextStyle(
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                DateFormat.yMMMd()
                                    .format(widget.snap['dateCom'].toDate()),
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid ==
                                widget.snap["uid"]
                            ? IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: ListView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        shrinkWrap: true,
                                        children: [
                                          "Delete",
                                        ]
                                            .map(
                                              (e) => InkWell(
                                                onTap: () async {
                                                  FirestoreMethods()
                                                      .deleteComment(
                                                          widget.snap["postId"],
                                                          widget.snap[
                                                              "commentId"]);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  child: Text(e),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.more_vert),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
