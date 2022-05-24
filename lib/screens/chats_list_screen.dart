import 'package:flutter/material.dart';
import 'package:lost_pet/utilities/colors.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({Key? key}) : super(key: key);

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: barColor,
      ),
      body: const Center(
        child: Text('Chats'),
      ),
    );
  }
}
