import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class Chatss extends StatefulWidget {
  const Chatss({Key? key}) : super(key: key);

  @override
  State<Chatss> createState() => _ChatssState();
}

class _ChatssState extends State<Chatss> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chats'),
      ),
      body: Center(
        child: Text('chats'),
      ),
    );
  }
}
