import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lost_pet/resources/firestore_methods.dart';
import 'package:lost_pet/screens/chat_screen.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({Key? key}) : super(key: key);

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  String currentUser = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  @override
  void initState() {
    super.initState();
/*     refreshChatsForCurrentUser(); */
  }

  @override
  void dispose() {
    super.dispose();
  }

  dynamic a = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: barColor,
      ),
      body: Container(
        color: webBackgroundColor,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where('users.$currentUser', isNull: true)
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
                itemBuilder: (context, index) {
                  Map<String, dynamic> data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  Map<String, dynamic> names = data['names'];
                  String lastMsg = data['lastMsg'];
                  dynamic lastTime = DateFormat('MMM d, h:mm a').format(
                    data["lastTime"].toDate(),
                  );

                  names.remove(currentUser);
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            friendUid: names.keys.first,
                            friendName: names.values.first,
                          ),
                        ));
                      },
                      child: Container(
                        color: mobileBackgroundColor,
                        margin: const EdgeInsets.all(10),
                        width: webScreenSize.toDouble(),
                        child: ListTile(
                          title: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            names.values.first,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                          Text(
                                            lastTime,
                                            style: const TextStyle(
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              lastMsg,
                                              style: const TextStyle(
                                                  color: primaryColor),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
