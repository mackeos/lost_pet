import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lost_pet/utilities/colors.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyWidget'),
        backgroundColor: barColor,
      ),
      body: Container(
        color: webBackgroundColor,
        child: const Center(
          child: Text('MyWidget'),
        ),
      ),
    );
  }
}
