import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lost_pet/resources/auth_methods.dart';
import 'package:lost_pet/responsive/mobile_layout.dart';
import 'package:lost_pet/responsive/responsive_layout.dart';
import 'package:lost_pet/responsive/web_layout.dart';
import 'package:lost_pet/screens/login_screen.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:lost_pet/widgets/text_field_input.dart';

import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _profileImage;

  bool _isLoading = false;

  void defaultImage() async {
    var imageData = await rootBundle.load('assets/user-avatar.png');
    setState(() {
      _profileImage = imageData.buffer.asUint8List();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _profileImage = null;
    super.dispose();
  }

  String? get _usernameErrorText {
    if (_usernameController.text.isEmpty) {
      return 'Username is required';
    }

    if (_usernameController.text.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (_usernameController.text.length > 15) {
      return 'Username must be less than 15 characters';
    }

    if (_usernameController.text.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    if (_usernameController.text.contains('@')) {
      return 'Username cannot contain @';
    }

    return null;
  }

  String? get _emailErrorText {
    if (_usernameController.text.isEmpty) {
      return 'Username is required';
    }

    if (_usernameController.text.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    return null;
  }

  String? get _passwordErrorText {
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (_passwordController.text.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    return null;
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

  void signupUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = "username contains unallowed characters";
    if (_usernameErrorText == null &&
        _emailErrorText == null &&
        _passwordErrorText == null) {
      res = await AuthMethods().signupUser(
        email: _emailController.text.toLowerCase(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        profileImage: _profileImage!,
      );
    }
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
      res = "${_usernameController.text} successfully signed up!";
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
    defaultImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: MediaQuery.of(context).size.width > webScreenSize
            ? Center(
                child: AspectRatio(
                  aspectRatio: 0.6720430107526881,
                  child: buildSignupColumn(context),
                ),
              )
            : buildSignupColumn(context),
      ),
    );
  }

  Container buildSignupColumn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                _profileImage != null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_profileImage!),
                      )
                    : const CircleAvatar(
                        radius: 64,
                        backgroundImage: AssetImage("assets/user-avatar.png"),
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
            TextFieldInput(
              hintText: "Email",
              keyboardType: TextInputType.emailAddress,
              textEditingController: _emailController,
              errorText: _emailErrorText,
              onChanged: (String) {
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldInput(
              hintText: "Username",
              keyboardType: TextInputType.text,
              textEditingController: _usernameController,
              errorText: _usernameErrorText,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldInput(
              hintText: "Password",
              keyboardType: TextInputType.text,
              textEditingController: _passwordController,
              obscureText: true,
              errorText: _passwordErrorText,
              onChanged: (String) {
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: signupUser,
              child: Container(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : const Text(
                        "Sign up",
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
          ],
        ),
      ),
    );
  }
}
