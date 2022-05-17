import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lost_pet/resources/auth_methods.dart';
import 'package:lost_pet/screens/login_screen.dart';
import 'package:lost_pet/utilities/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            NetworkImage("https://picsum.photos/200"),
                        radius: 50,
                      ),
                      TextButton(
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
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }
}







/* import 'package:flutter/material.dart';
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
} */
