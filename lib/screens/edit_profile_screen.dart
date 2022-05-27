import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lost_pet/resources/firestore_methods.dart';
import 'package:lost_pet/resources/storage_methods.dart';
import 'package:lost_pet/responsive/mobile_layout.dart';
import 'package:lost_pet/responsive/responsive_layout.dart';
import 'package:lost_pet/responsive/web_layout.dart';

import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:lost_pet/widgets/text_field_input.dart';

import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUid;
  const EditProfileScreen({Key? key, required this.currentUid})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _profileImage;

  var userData = {};

  bool _isLoading = false;

  getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUid)
          .get();

      setState(() {
        userData = userSnapshot.data()!;
        _usernameController.text = userData['username'];
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _profileImage = null;
    super.dispose();
  }

  void selectImage(context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select a profile image'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a picture'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List image = await pickImage(
                  ImageSource.camera,
                );
                setState(() {
                  _profileImage = image;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List image = await pickImage(
                  ImageSource.gallery,
                );
                setState(() {
                  _profileImage = image;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void editProfile() async {
    setState(() {
      _isLoading = true;
    });

    if (_profileImage != null) {
      String imageUrl = await StorageMethods()
          .uploadImageToStorage('profile_images', _profileImage!, false);
      userData['profileImage'] = imageUrl;
    }

    String res = await FirestoreMethods().editProfile(
      uid: FirebaseAuth.instance.currentUser!.uid,
      username: _usernameController.text.trim().toLowerCase(),
      profileImage: userData['profileImage'],
    );
    setState(() {
      _isLoading = false;
    });

    if (res == 'Success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileLayout(),
            webScreenLayout: WebLayout(),
          ),
        ),
      );
      res = "Profile Edit Complete";
      showSnackBar(
        context,
        res,
      );
    } else {
      showSnackBar(
        context,
        res,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Container(), flex: 2),
                  Stack(
                    children: [
                      _profileImage != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_profileImage!),
                            )
                          : CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  NetworkImage(userData['profileImage']),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () => selectImage(context),
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldInput(
                    hintText: userData['username'],
                    keyboardType: TextInputType.text,
                    textEditingController: _usernameController,
                    onChanged: (String) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: editProfile,
                    child: Container(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                          : const Text(
                              "Confirm edit",
                            ),
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        color: blueColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                ],
              ),
            ),
    );
  }
}
