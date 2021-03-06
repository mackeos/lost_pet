import 'package:flutter/material.dart';

import 'package:lost_pet/resources/auth_methods.dart';

import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:lost_pet/widgets/text_field_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  void resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().resetPassword(
      email: _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (res == 'Success') {
      Navigator.pop(context);
      res =
          "Check your email to reset your password.\nEmail might be in your spam folder.";
    } else {
      res = "Email not found! $res";
    }

    showSnackBar(
      context,
      res,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: barColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: MediaQuery.of(context).size.width > webScreenSize
            ? Center(
                child: AspectRatio(
                  aspectRatio: 0.6720430107526881,
                  child: buildColumn(context),
                ),
              )
            : buildColumn(context),
      ),
    );
  }

  Container buildColumn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: Container(), flex: 2),
          const SizedBox(
            height: 20,
          ),
          TextFieldInput(
            hintText: "Email",
            keyboardType: TextInputType.emailAddress,
            textEditingController: _emailController,
            onChanged: (String) {
              setState(() {});
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : resetPassword,
            child: Container(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : const Text(
                      "Reset Password",
                    ),
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(blueColor),
            ),
          ),
          Flexible(child: Container(), flex: 2),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
