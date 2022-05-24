import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:bubble/bubble.dart';
import 'package:lost_pet/utilities/global_variables.dart';

class ChatScreen extends StatefulWidget {
  final String friendUid;
  final String friendName;

  const ChatScreen(
      {Key? key, required this.friendUid, required this.friendName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  var chatId;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    await chats
        .where('users', isEqualTo: {widget.friendUid: null, currentUid: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatId = querySnapshot.docs.single.id;
              });
            } else {
              await chats.add({
                'users': {currentUid: null, widget.friendUid: null},
                'names': {
                  currentUid: FirebaseAuth.instance.currentUser!.displayName,
                  widget.friendUid: widget.friendName
                }
              }).then((value) => {chatId = value});
            }
          },
        )
        .catchError((error) {});
  }

  void sendMessage(String msg) {
    if (msg == '') return;
    chats.doc(chatId).collection('messages').add({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': currentUid,
      'friendName': widget.friendName,
      'msg': msg
    }).then((value) {
      _textController.text = '';
    });
  }

  bool isSender(String friend) {
    return friend == currentUid;
  }

  Alignment getAlignment(friend) {
    if (friend == currentUid) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chats
          .doc(chatId)
          .collection('messages')
          .orderBy('createdOn', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          var data;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: barColor,
              title: Text(widget.friendName),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: MediaQuery.of(context).size.width > webScreenSize
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: 0.6720430107526881,
                        child: BuildColumn(snapshot, data),
                      ),
                    )
                  : BuildColumn(snapshot, data),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Column BuildColumn(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, dynamic data) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            reverse: true,
            children: snapshot.data!.docs.map(
              (DocumentSnapshot document) {
                data = document.data()!;

                return BuildBubble(data['msg'], data['uid']);
              },
            ).toList(),
          ),
        ),
        Container(
          color: barColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (String msg) {
                      sendMessage(msg);
                    },
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.send_sharp),
                  onPressed: () => sendMessage(_textController.text))
            ],
          ),
        )
      ],
    );
  }

  Bubble BuildBubble(String msg, String id) {
    return Bubble(
      margin: BubbleEdges.fromLTRB(
          isSender(id) ? 40 : 5, 5, isSender(id) ? 5 : 40, 5),
      alignment: getAlignment(id),
      color: isSender(id) ? Colors.white : Colors.blue[200],
      child: Text(
        msg,
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.left,
      ),
    );
  }
}
