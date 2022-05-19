import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: const Text("Feed"),
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
                  itemBuilder: (context, index) =>
                      PostCard(snap: snapshot.data!.docs[index].data()),
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
                  itemBuilder: (context, index) =>
                      PostCard(snap: snapshot.data!.docs[index].data()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
