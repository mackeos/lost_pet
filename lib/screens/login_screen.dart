import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lost_pet/resources/auth_methods.dart';
import 'package:lost_pet/responsive/responsive_layout.dart';
import 'package:lost_pet/responsive/mobile_layout.dart';
import 'package:lost_pet/responsive/web_layout.dart';
import 'package:lost_pet/screens/forgot_password_screen.dart';
import 'package:lost_pet/screens/signup_screen.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';
import 'package:lost_pet/utilities/utilities.dart';
import 'package:lost_pet/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
      email: _emailController.text.toLowerCase(),
      password: _passwordController.text,
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
      res = "successfully Logged in!";
    } else {
      res = "Login failed! $res";
    }
    showSnackBar(
      context,
      res,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MediaQuery.of(context).size.width > webScreenSize
            ? Center(
                child: AspectRatio(
                  aspectRatio: 0.6720430107526881,
                  child: buildLoginColumn(context),
                ),
              )
            : buildLoginColumn(context),
      ),
    );
  }

  Container buildLoginColumn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: Container(), flex: 2),
          SvgPicture.asset(
            "assets/logo.svg",
            color: primaryColor,
            height: 100,
          ),
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
          TextFieldInput(
            hintText: "Password",
            keyboardType: TextInputType.text,
            textEditingController: _passwordController,
            obscureText: true,
            onChanged: (String) {
              setState(() {});
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Forgot Password?")),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: loginUser,
            child: Container(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : const Text(
                      "Login",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: const Text("Don't have an account? "),
                padding: const EdgeInsets.symmetric(vertical: 2),
              ),
              GestureDetector(
                onTap: _isLoading
                    ? () {}
                    : () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const SignupScreen()));
                      },
                child: Container(
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
