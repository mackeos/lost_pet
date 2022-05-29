import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';
import 'package:lost_pet/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: barColor,
          title: width > webScreenSize
              ? const Text(
                  "Feed",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              : Image.asset(
                  "assets/pets-logo-white.png",
                  height: 30,
                ),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Lost Pets",
              ),
              Tab(
                text: "Found Pets",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("type", isEqualTo: "lost")
                  .orderBy("datePosted", descending: true)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: width > webScreenSize ? 15 : 0),
                      width: webScreenSize.toDouble(),
                      child: PostCard(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("type", isEqualTo: "found")
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: width > webScreenSize ? 15 : 0),
                      width: webScreenSize.toDouble(),
                      child: PostCard(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
