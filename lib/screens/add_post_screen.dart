import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_pet/resources/firestore_methods.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/providers.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _imageTOUpload;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  List<bool> _uploadTypeToggle = [true, false];

  void postImage(
    String uid,
    String username,
    String profileImage,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _imageTOUpload!,
        uid,
        username,
        profileImage,
        _uploadTypeToggle[0] ? "lost" : "found",
      );

      if (res == 'Success') {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, "Post uploaded successfully");
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, e.toString());
    }
  }

  void selectImage(context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select an image'),
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
                  _imageTOUpload = image;
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
                  _imageTOUpload = image;
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

  void clearImage() {
    setState(() {
      _imageTOUpload = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return _imageTOUpload == null
        ? Center(
            child: IconButton(
              onPressed: (() => selectImage(context)),
              icon: const Icon(Icons.add),
              color: Colors.white,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Add Post'),
              actions: [
                TextButton(
                  onPressed: () => postImage(
                    user.uid,
                    user.username,
                    user.profileImage,
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator(
                        minHeight: 3.0,
                      )
                    : const SizedBox(
                        height: 3.0,
                      ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.profileImage,
                      ),
                    ),
                    const Text(
                      'Upload Type',
                    ),
                    ToggleButtons(
                      borderColor: primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      borderWidth: 1,
                      selectedColor: blueColor,
                      hoverColor: blueColor,
                      fillColor: primaryColor,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Lost',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Found',
                          ),
                        ),
                      ],
                      isSelected: _uploadTypeToggle,
                      onPressed: (int newIndex) {
                        setState(() {
                          for (int index = 0;
                              index < _uploadTypeToggle.length;
                              index++) {
                            if (index == newIndex) {
                              _uploadTypeToggle[index] = true;
                            } else {
                              _uploadTypeToggle[index] = false;
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: MemoryImage(
                                  _imageTOUpload!,
                                ),
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your post description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    maxLength: 150,
                    maxLines: 3,
                  ),
                ),
                const Divider(
                  color: primaryColor,
                ),
              ],
            ),
          );
  }
}
