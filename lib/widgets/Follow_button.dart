import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? onPressed;
  final Color buttonColor;
  final Color borderColor;
  final String text;
  final Color textColor;
  const FollowButton({
    Key? key,
    this.onPressed,
    required this.buttonColor,
    required this.borderColor,
    required this.text,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: TextButton(
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: borderColor, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          width: 250,
          height: 30,
        ),
      ),
    );
  }
}
