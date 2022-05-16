import 'package:flutter/material.dart';
import 'package:lost_pet/resources/auth_methods.dart';
import 'package:lost_pet/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          await AuthMethods().signOutUser();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        },
        child: Text("Sign Out"),
      ),
    );
  }
}
