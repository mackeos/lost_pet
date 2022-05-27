import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/resources/firestore_methods.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:bubble/bubble.dart';
import 'package:lost_pet/utilities/global_variables.dart';
import 'package:uuid/uuid.dart';

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
    String username = '';
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currentUid)
        .get()
        .then((value) => username = value.docs[0].data()['username']);

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
              String chatRoomId = const Uuid().v1();
              await chats.add({
                'users': {currentUid: null, widget.friendUid: null},
                'names': {
                  currentUid: username,
                  widget.friendUid: widget.friendName
                },
                "chatRoomId": chatRoomId
              }).then((value) => {chatId = value.id});
            }
          },
        )
        .catchError((error) {});

    setState(() {});
  }

  void sendMessage(String msg) {
    if (msg == '') return;
    msg = msg.trim();
    var sendTime = DateTime.now();
    chats.doc(chatId).update(
        {'lastMsg': msg, 'lastSender': currentUid, 'lastTime': sendTime});
    chats.doc(chatId).collection('messages').add({
      'createdOn': sendTime,
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
          return const Center(
            child: const Text("Something went wrong"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.friendName),
              backgroundColor: barColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Container(
              color: mobileBackgroundColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasData) {
          var data;
          return Scaffold(
            backgroundColor: webBackgroundColor,
            appBar: AppBar(
              backgroundColor: barColor,
              title: Text(widget.friendName),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
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
          child: Container(
            color: mobileBackgroundColor,
            child: ListView(
              reverse: true,
              children: snapshot.data!.docs.map(
                (DocumentSnapshot document) {
                  data = document.data();
                  return BuildBubble(data['msg'], data['uid']);
                },
              ).toList(),
            ),
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
                    decoration: const InputDecoration(
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
                icon: const Icon(Icons.send_sharp),
                onPressed: () {
                  sendMessage(_textController.text);
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Bubble BuildBubble(String msg, String id) {
    return Bubble(
      margin: BubbleEdges.fromLTRB(
          isSender(id) ? 50 : 5, 5, isSender(id) ? 5 : 50, 5),
      alignment: getAlignment(id),
      color: isSender(id) ? Colors.white : Colors.blue[200],
      child: Text(
        msg,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
